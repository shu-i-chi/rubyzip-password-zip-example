require "zip"
require "pathname"
require "tempfile"

require_relative "zip_generator/errors"
require_relative "zip_generator/file_entry"

# ZIPファイル生成処理を扱うモジュールです。
module ZipGenerator
  # ZIPファイルを新規作成します。オプション引数でパスワードを渡すと、パスワード付きZIPファイルを新規作成します
  #
  # ZIPファイルに収録するエントリー名（つまり、ZIPファイル展開後のファイル名）は、パスのうちファイル名の部分（basename）です。
  # ZIPファイルに含めるファイルは、ファイル名部分（basename）に重複がないようにしてください。
  #   OK: foo/file_1, bar/file_2, bar/baz/file_3 #=> file_1, file_2, file_3
  #   NG: foo/file_1, bar/file_2, bar/baz/file_2 #=> X 'file_2'が重複
  #
  # @example 通常のZIPファイルを作成する
  #   files = ["path/to/file_1", "path/to/file_2"]
  #   zip_path = "path/to/created/zipfile.zip"
  #
  #   ZipGenerator.zip_archive(files, zip_path)
  #   #=> path/to/created/zipfile.zipファイルが作成される
  #
  # @example パスワード付きZIPファイルを作成する
  #   files = ["path/to/file_1", "path/to/file_2"]
  #   zip_path = "path/to/created/zipfile.zip"
  #   password = "foobarbaz"
  #
  #   ZipGenerator.zip_archive(files, zip_path, password: password)
  #   #=> path/to/created/zipfile.zipファイルが作成される
  #
  # @param archived_filepaths [Array<String>] ZIPファイルにまとめるファイルのパス（String）を格納した配列を指定します。
  #   ZIPファイルに収録するエントリー名（つまり、ZIPファイル展開後のファイル名）は、パスのうちファイル名の部分（basename）です。
  # @param zip_path [String] 生成するZIPファイルのパスを指定します。
  # @param password [String] パスワードの文字列です。パスワード付きZIPファイルを作成する場合に指定します。
  # @return [Integer] 新規作成したZIPファイルに書き込んだByte数です。
  #   {https://docs.ruby-lang.org/ja/latest/class/IO.html#S_WRITE File#write}由来の値です。
  # @raise [FileBasenameDuplicationError] 引数archived_filepathsに指定したファイルパスの中に、
  #   ファイル名（basename）の重複がある場合に、発生する例外です。
  #   重複がある場合に、ZIPファイルを展開した際のファイル名をどうするのか考えるのが面倒なので、例外にしています。
  # @raise [NotExistingFileError] 引数archived_filepathsに指定したファイルパスの中に、
  #   実際には存在しないものが含まれていた場合に、発生する例外です。
  # @raise [NotExistingDirError] 引数zip_pathに指定したファイルパスが、存在しないディレクトリを含んでいる場合に、
  #   発生する例外です。
  def self.zip_archive(archived_filepaths, zip_path, password: nil)
    if not FileTest.exist?(Pathname(zip_path).dirname)
      raise NotExistingDirError.new(message="出力するZIPファイルに指定したファイルパスが、存在しないディレクトリを含んでいます", path: zip_path)
    end

    buffer = get_zip_buffer(archived_filepaths, password: password)

    File.open(zip_path, "wb") { |f| f.write(buffer.string) }
  end

  # ZIPファイルをTempfileとして作成し、Tempfileオブジェクトを返します。オプション引数でパスワードを渡すと、パスワード付きZIPファイルを作成します
  #
  # ZIPファイルに収録するエントリー名（つまり、ZIPファイル展開後のファイル名）は、パスのうちファイル名の部分（basename）です。
  # ZIPファイルに含めるファイルは、ファイル名部分（basename）に重複がないようにしてください。
  #   OK: foo/file_1, bar/file_2, bar/baz/file_3 #=> file_1, file_2, file_3
  #   NG: foo/file_1, bar/file_2, bar/baz/file_2 #=> X 'file_2'が重複
  #
  # {ZipGenerator.zip_archive}との違いは、以下のとおりです：
  # * ディスク上への永続化を目的としていないので、ファイル名を扱わない
  # * Tempfileオブジェクトを直接返す
  #
  # {Zip::OutputStream.write_buffer}で得られるStringIOを直接使わずに、Tempfileとして取り回すモチベーションは、
  # 例えば大量にZIPファイルを作成する場合などに、メモリ上にデータを持っておきたくない、というところにあります。
  #
  # @see https://docs.ruby-lang.org/ja/latest/class/Tempfile.html Tempfile（Rubyリファレンスマニュアル）
  #
  # @example
  #   files = ["path/to/file_1", "path/to/file_2"]
  #   tempfile = ZipGenerator.get_zip_tempfile(files)
  #
  #   data = File.read(tempfile)
  #   tempfile.close!
  #
  #   File.open("zipfile.zip", "w") { |f| f.write(data) }
  #
  # @param archived_filepaths [Array<String>] ZIPファイルにまとめるファイルのパス（String）を格納した配列を指定します。
  #   ZIPファイルに収録するエントリー名（つまり、ZIPファイル展開後のファイル名）は、パスのうちファイル名の部分（basename）です。
  # @param password [String] パスワードの文字列です。パスワード付きZIPファイルを作成する場合に指定します。
  # @return [Tempfile]
  # @raise [FileBasenameDuplicationError] 引数archived_filepathsに指定したファイルパスの中に、
  #   ファイル名（basename）の重複がある場合に、発生する例外です。
  #   重複がある場合に、ZIPファイルを展開した際のファイル名をどうするのか考えるのが面倒なので、例外にしています。
  # @raise [NotExistingFileError] 引数archived_filepathsに指定したファイルパスの中に、
  #   実際には存在しないものが含まれていた場合に、発生する例外です。
  def self.get_zip_tempfile(archived_filepaths, password: nil)
    buffer = get_zip_buffer(archived_filepaths, password: password)

    Tempfile.open do |fp|
      fp.write(buffer.string)
      fp
    end
  end

  # ZIPファイルのStringIOオブジェクトを生成して返します。オプション引数でパスワードを渡すと、パスワード付きZIPファイルを作成します
  #
  # ZIPファイルに収録するエントリー名（つまり、ZIPファイル展開後のファイル名）は、パスのうちファイル名の部分（basename）です。
  # ZIPファイルに含めるファイルは、ファイル名部分（basename）に重複がないようにしてください。
  #   OK: foo/file_1, bar/file_2, bar/baz/file_3 #=> file_1, file_2, file_3
  #   NG: foo/file_1, bar/file_2, bar/baz/file_2 #=> X 'file_2'が重複
  #
  # @example
  #   files = ["path/to/file_1", "path/to/file_2"]
  #   buffer = ZipGenerator.get_zip_buffer(files) # StringIO
  #   
  #   File.open("zipfile.zip", "w") { |f| f.write(buffer.string) }
  #
  # @see https://docs.ruby-lang.org/ja/3.1/class/StringIO.html StringIO（Rubyリファレンスマニュアル）
  #
  # @param archived_filepaths [Array<String>] ZIPファイルにまとめるファイルのパス（String）を格納した配列を指定します。
  #   ZIPファイルに収録するエントリー名（つまり、ZIPファイル展開後のファイル名）は、パスのうちファイル名の部分（basename）です。
  # @param password [String] パスワードの文字列です。パスワード付きZIPファイルを作成する場合に指定します。
  # @return [StringIO]
  # @raise [FileBasenameDuplicationError] 引数archived_filepathsに指定したファイルパスの中に、
  #   ファイル名（basename）の重複がある場合に、発生する例外です。
  #   重複がある場合に、ZIPファイルを展開した際のファイル名をどうするのか考えるのが面倒なので、例外にしています。
  # @raise [NotExistingFileError] 引数archived_filepathsに指定したファイルパスの中に、
  #   実際には存在しないものが含まれていた場合に、発生する例外です。
  def self.get_zip_buffer(archived_filepaths, password: nil)
    file_entries = archived_filepaths
                     .map { |path| FileEntry.new(entry_name: File.basename(path), filepath: path) }

    # ファイル名部分（basename）に重複がある場合は例外にする。
    duplications = basename_duplicated_paths(file_entries)

    if duplications.size != 0
      raise FileBasenameDuplicationError.new(filepaths: duplications)
    end

    # ZIPファイルのStringIOを生成
    enc = password ? Zip::TraditionalEncrypter.new(password) : nil

    Zip::OutputStream.write_buffer(StringIO.new(""), enc) do |output|
      file_entries.each do |file_entry|
        output.put_next_entry(file_entry.entry_name)

        filepath = file_entry.filepath

        if FileTest.exist?(filepath)
          file_data = File.read(filepath)
          output.write(file_data)
        else
          raise NotExistingFileError.new(path: filepath)
        end
      end
    end
  end

  # # プライベートクラスメソッドにしたい場合は、コメントアウトを外す
  # private_class_method :get_zip_buffer

  # {fileentry}の配列について、重複しているファイルパスの配列を返します。
  #
  # @param file_entries [Array<FileEntry>] {FileEntry}の配列です
  # @return [Array<String>]
  def self.basename_duplicated_paths(file_entries)
    duplicated_basenames = file_entries
                             .map { |file_entry| File.basename(file_entry.filepath) }
                             .tally
                             .reject { |basename, num| num == 1 }
                             .keys

    file_entries
      .map { |file_entry| file_entry.filepath }
      .select { |filepath| duplicated_basenames.include?(File.basename(filepath)) }
  end

  private_class_method :basename_duplicated_paths
end
