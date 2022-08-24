module ZipGenerator
  # ZIPファイルエントリーの情報を格納するためのStructです。
  #
  # @!attribute [rw] entry_name
  #   ZIPファイルのエントリー名です。ZIPファイルを展開した際のファイルパスになります
  #   @return [String]
  # @!attribute [rw] filepath
  #   ZIPファイルに含めるファイルの、実際のパスです
  #   @return [String]
  FileEntry = Struct.new(:entry_name, :filepath, keyword_init: true)
end
