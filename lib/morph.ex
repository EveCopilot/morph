defmodule Morph do
  @moduledoc """
  Documentation for `Morph`.
  """

  def process(source, type) do
    open(source, type)
    |> unzip()
    |> Unzip.list_entries()
    |> Flow.from_enumerable()
    |> Flow.map(&process_entry(&1, source, type))
    |> Flow.run()
  end

  def open(source, :local) do
    Unzip.LocalFile.open(source)
  end

  def open(source, :s3) do
    Morph.S3File.new(s3_bucket(source), s3_key(source))
  end

  def unzip(zip_file) do
    # `new` reads list of files by reading central directory found at the end of the zip
    {:ok, unzip} = Unzip.new(zip_file)

    unzip
  end

  def process_entry(entry, source, type) do
    open(source, type)
    |> unzip()
    |> Unzip.file_stream!(entry.file_name)
    |> into_string()
    |> YamlElixir.read_from_string!()
    |> encode!(file_type(entry.file_name))
    |> write_file!("#{file_name(entry.file_name)}.ndjson")
  end

  def into_string(stream) do
    stream
    |> Enum.into([])
    |> IO.iodata_to_binary()
  end

  def encode!(data, :set) do
    Enum.map(data, fn {k, v} -> Map.put(v, :id, k) |> Jason.encode!() end)
    |> Enum.join("\n")
  end

  def encode!(data, :list) do
    Enum.map(data, &Jason.encode!/1)
    |> Enum.join("\n")
  end

  def encode!(data, :object) do
    Jason.encode!(data)
  end

  def write_file!(content, path) do
    File.mkdir_p!(file_path(path))

    File.write!(path, content)
  end

  def file_type("sde/fsd/universe/" <> _suffix), do: :object
  def file_type("sde/fsd/tournamentRuleSets.yaml"), do: :list
  def file_type("sde/fsd/translationLanguages.yaml"), do: :object
  def file_type("sde/fsd/" <> _suffix), do: :set
  def file_type("sde/bsd/" <> _suffix), do: :list

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
