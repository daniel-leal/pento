defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view

  alias Pento.Accounts

  def mount(_params, %{"user_token" => user_token} = session, socket) do
    {:ok,
     assign(
       socket,
       score: 0,
       message: "Make a guess",
       magical_number: Enum.random(1..10),
       correct: false,
       session_id: session["live_socket_id"],
       current_user: Accounts.get_user_by_session_token(user_token)
     )}
  end

  def render(assigns) do
    ~H"""
    <h1>Your score: <%= @score %></h1>
    <h2>
      <%= @message %>
      <%= if @correct do %>
        <%= live_patch "Restart", to: Routes.live_path(@socket, PentoWeb.WrongLive, %{score: @score}) %>
      <% end %>
      <pre>
      <%= @current_user.email %>
      <%= @session_id %>
      </pre>
    </h2>
    <h2>
    <%= for n <- 1..10 do %>
      <a href="#" phx-click="guess" phx-value-number= {n} ><%= n %></a>
    <% end %>
    </h2>
    """
  end

  def handle_event("guess", %{"number" => guess} = _data, socket) do
    magical_number = socket.assigns.magical_number
    guess = String.to_integer(guess)
    correct = magical_number == guess
    message = if correct, do: "Correct! ", else: "Your guess: #{guess}. Wrong. Guess again. "
    score = socket.assigns.score + if correct, do: 1, else: -1

    {
      :noreply,
      assign(
        socket,
        message: message,
        score: score,
        correct: correct
      )
    }
  end
end
