defmodule Morph do
  @moduledoc """
  Documentation for `Morph`.
  """

  def process(source) do
    get_entries(source)
    |> Flow.from_enumerable()
    |> Flow.map(&process_entry(&1, source))
    |> Flow.run()
  end

  def get_entries(source) do
    zip_file = open_zipfile(source)

    entries =
      unzip(zip_file)
      |> Unzip.list_entries()

    close_zipfile(zip_file)

    entries
  end

  def open_zipfile(source) do
    Unzip.LocalFile.open(source)
  end

  def close_zipfile(zip_file) do
    Unzip.LocalFile.close(zip_file)
  end

  def unzip(zip_file) do
    # `new` reads list of files by reading central directory found at the end of the zip
    {:ok, unzip} = Unzip.new(zip_file)

    unzip
  end

  def process_entry(entry, source) do
    IO.puts("Processing #{entry.file_name}")

    zip_file = open_zipfile(source)

    unzip(zip_file)
    |> Unzip.file_stream!(entry.file_name)
    |> into_string()
    |> YamlElixir.read_from_string!()
    |> encode!(file_type(entry.file_name))
    |> write_file!("#{file_name(entry.file_name)}.ndjson")

    close_zipfile(zip_file)

    IO.puts("Finished processing #{entry.file_name}")
  end

  def into_string(stream) do
    stream
    |> Enum.into([])
    |> IO.iodata_to_binary()
  end

  def encode!(data, :set) do
    Enum.map(data, fn {k, v} -> Map.put(v, :id, k) |> JSON.encode!() end)
    |> Enum.join("\n")
  end

  def encode!(data, :list) do
    Enum.map(data, &JSON.encode!/1)
    |> Enum.join("\n")
  end

  def encode!(data, :object) do
    JSON.encode!(data)
  end

  def write_file!(content, path) do
    File.mkdir_p!(file_path(path))

    File.write!(path, content)
  end

  def file_type("bsd/" <> _suffix), do: :list
  def file_type("fsd/tournamentRuleSets.yaml"), do: :list
  def file_type("fsd/translationLanguages.yaml"), do: :object
  def file_type("fsd/" <> _suffix), do: :set
  def file_type("universe/" <> _suffix), do: :object

  def file_name(prefix) do
    prefix
    |> String.split(".")
    |> Enum.drop(-1)
    |> Enum.join(".")
  end

  def file_path(path) do
    path
    |> String.split("/")
    |> Enum.drop(-1)
    |> Enum.join("/")
  end

  def s3_bucket(source) do
    source
    |> String.split("/")
    |> Enum.at(0)
  end

  def s3_key(source) do
    source
    |> String.split("/")
    |> Enum.drop(1)
    |> Enum.join("/")
  end
end
