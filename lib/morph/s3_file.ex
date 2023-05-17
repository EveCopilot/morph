defmodule Morph.S3File do
  defstruct [:bucket, :path, :s3_config]
  alias __MODULE__

  def new(bucket, path) do
    %S3File{bucket: bucket, path: path, s3_config: ExAws.Config.new(:s3)}
  end
end

defimpl Unzip.FileAccess, for: Morph.S3File do
  alias ExAws.S3

  def size(file) do
    %{headers: headers} = S3.head_object(file.bucket, file.path) |> ExAws.request!(file.s3_config)

    size =
      headers
      |> Enum.find(fn {k, _} -> String.downcase(k) == "content-length" end)
      |> elem(1)
      |> String.to_integer()

    {:ok, size}
  end

  def pread(file, offset, length) do
    {_, chunk} =
      S3.Download.get_chunk(
        %S3.Download{bucket: file.bucket, path: file.path, dest: nil},
        %{start_byte: offset, end_byte: offset + length - 1},
        file.s3_config
      )

    {:ok, chunk}
  end
end