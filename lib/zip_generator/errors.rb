module ZipGenerator
  # エラーのための基底クラスです。
  class BaseError < StandardError
    # エラーメッセージを生成して返します。追加情報がある場合は、メッセージ末尾に追記します
    #
    # 追記部分の書式は、`：<追加情報>`です。
    #
    # @example
    #   error_message("エラーメッセージ")
    #   #=> "エラーメッセージ"
    #
    #   error_message("エラーメッセージ", "追加情報")
    #   #=> "エラーメッセージ：追加情報"
    #
    # @param message [String] 基本のエラーメッセージを指定します。
    # @param additional_item [String] 追加情報がある場合に指定します。
    # @return [String]
    def error_message(message, additional_item = nil)
      _message = message

      if additional_item
        _message << "：#{additional_item}"
      end

      _message
    end
  end

  # ZIPファイルに含めようとしているファイル名(basename)に重複がある時に発生する例外です。
  #
  # 重複がある場合に、ZIPファイルを展開した際のファイル名をどうするのか考えるのが面倒なので、例外にしています。
  class FileBasenameDuplicationError < BaseError
    # {FileBasenameDuplicationError}のインスタンスを返します。オプションで「重複しているファイル名」をエラーメッセージに含めることができます
    #
    # @param message [String] エラーメッセージを指定します。
    # @param filepaths [Array<String>] エラーメッセージに「重複しているファイルパス」を含めたい場合に指定します。
    def initialize(message = "ZIPファイルに含めようとしているファイル名(basename)に重複があります", filepaths: nil)
      _filepaths = (filepaths.class == Array && filepaths.size > 0) ? filepaths.join(", ") : nil

      super(error_message(message, _filepaths))
    end
  end

  # 存在しないファイルパスを指定した場合に発生する例外です。
  class NotExistingFileError < BaseError
    # {NotExistingFileError}のインスタンスを返します。オプションで「存在しないファイルパス」をエラーメッセージに含めることができます
    #
    # @param message [String] エラーメッセージを指定します。
    # @param path [String] エラーメッセージに「存在しないファイルパス」を含めたい場合に指定します。
    def initialize(message = "指定したファイルは存在しません", path: nil)
      super(error_message(message, path))
    end
  end

  # 存在しないディレクトリを含むファイルパスを指定した場合に発生する例外です。
  class NotExistingDirError < BaseError
    # {NotExistingDirError}のインスタンスを返します。オプションで「存在しないディレクトリを含むファイルパス」をエラーメッセージに含めることができます
    #
    # @param message [String] エラーメッセージを指定します。
    # @param path [String] エラーメッセージに「存在しないディレクトリを含むファイルパス」を含めたい場合に指定します。
    def initialize(message = "存在しないディレクトリが含まれています", path: nil)
      super(error_message(message, path))
    end
  end
end
