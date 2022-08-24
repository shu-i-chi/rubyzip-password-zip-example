require_relative "lib/zip_generator"

#
# ZIPファイルに含めるファイル
#
def files
  files = ["tmp/file_1", "tmp/file_2"]

  files.each do |filepath|
    File.open(filepath, "w") do |f|
      f.print "ファイル：#{filepath}"
    end
  end

  files
end

@files ||= files

#
# ZipGenerator.get_zip_buffer
#
puts "EXAMPLE 1. -- ZipGenerator.get_zip_buffer"

zipfile_1 = "tmp/zipfile_buffer.zip"
zipfile_pw_1 = "tmp/zipfile_buffer_pw.zip"
password_1 = "buffer"

puts " > ZIPファイル [ #{zipfile_1} ] を作成"
buffer = ZipGenerator.get_zip_buffer(@files) # StringIO
File.open(zipfile_1, "w") { |f| f.write(buffer.string) }

puts " > パスワード付きZIPファイル [ #{zipfile_pw_1} ] を作成（パスワード：#{password_1}）"
buffer_pw = ZipGenerator.get_zip_buffer(@files, password: password_1) # StringIO
File.open(zipfile_pw_1, "w") { |f| f.write(buffer_pw.string) }

#
# ZipGenerator.get_zip_tempfile
#
puts "\nEXAMPLE 2. -- ZipGenerator.get_zip_tempfile"

zipfile_2 = "tmp/zipfile_tempfile.zip"
zipfile_pw_2 = "tmp/zipfile_tempfile_pw.zip"
password_2 = "tempfile"

puts " > ZIPファイル [ #{zipfile_2} ] を作成"
tempfile = ZipGenerator.get_zip_tempfile(@files)

data = File.read(tempfile)
tempfile.close!

File.open(zipfile_2, "w") { |f| f.write(data) }

puts " > パスワード付きZIPファイル [ #{zipfile_pw_2} ] を作成（パスワード：#{password_2}）"
tempfile_pw = ZipGenerator.get_zip_tempfile(@files, password: password_2)

data_pw = File.read(tempfile_pw)
tempfile_pw.close!

File.open(zipfile_pw_2, "w") { |f| f.write(data_pw) }

#
# ZipGenerator.zip_archive
#
puts "\nEXAMPLE 3. -- ZipGenerator.zip_archive"

zipfile_3 = "tmp/zipfile_file.zip"
zipfile_pw_3 = "tmp/zipfile_file_pw.zip"
password_3 = "file"

puts " > ZIPファイル [ #{zipfile_3} ] を作成"
ZipGenerator.zip_archive(@files, zipfile_3)

puts " > パスワード付きZIPファイル [ #{zipfile_pw_3} ] を作成（パスワード：#{password_3}）"
ZipGenerator.zip_archive(@files, zipfile_pw_3, password: password_3)
