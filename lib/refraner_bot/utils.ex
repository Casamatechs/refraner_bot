defmodule RefranerBot.Utils do
  def pretty_refran(%{refran: refran, id: id}), do: "📜 _#{refran}_ 📜"

  defp filter_null_params(list) do
    Enum.filter(list, fn {_, v} -> v != nil end)
  end

  def check_info(refran) do
    case refran |> Map.to_list() |> filter_null_params do
      [] -> :no_info
      _ -> :ok_info
    end
  end

  def generate_rating_row(refran_id) do
    refran_id = id_to_string(refran_id)

    [
      [text: "😡", callback_data: "rate_refran:1:" <> refran_id],
      [text: "☹", callback_data: "rate_refran:2:" <> refran_id],
      [text: "🙃", callback_data: "rate_refran:3:" <> refran_id],
      [text: "😄", callback_data: "rate_refran:4:" <> refran_id],
      [text: "😍", callback_data: "rate_refran:5:" <> refran_id]
    ]
  end

  defp format_key(key) when is_atom(key), do: key |> Atom.to_string()

  defp format_key(key) when is_binary(key) do
    key
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  def pretty_refran_info(refran) do
    text = Map.get(refran, :refran)
    refran_text = "📜 _#{text}_ 📜\n\n"
    Map.to_list(refran) |> filter_null_params() |> pretty_refran_info(refran_text)
  end

  defp pretty_refran_info([{_, nil} | rest], string) do
    pretty_refran_info(rest, string)
  end

  defp pretty_refran_info([{key, info} | rest], string) do
    formatted_key = format_key(key)
    pretty_refran_info(rest, string <> "*#{formatted_key}:* #{info}\n")
  end

  defp pretty_refran_info([_ | rest], string) do
    pretty_refran_info(rest, string)
  end

  defp pretty_refran_info([], string) do
    string
  end

  def generate(refran_id, raw_buttons) do
    refran_id = id_to_string(refran_id)

    buttons = Enum.map(raw_buttons, fn raw_button -> get_button(refran_id, raw_button) end)

    Telex.Dsl.create_inline(buttons)
  end

  defp get_button(refran_id, :hide),
    do: [[text: "Hide info", callback_data: "action:hide_refran_info:" <> refran_id]]

  defp get_button(refran_id, :rate), do: generate_rating_row(refran_id)

  defp get_button(refran_id, :show),
    do: [[text: "Show info", callback_data: "action:show_refran_info:" <> refran_id]]

  def id_to_string(id) when is_integer(id), do: Integer.to_string(id)
  def id_to_string(id) when is_binary(id), do: id
end
