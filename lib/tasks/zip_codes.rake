require "zip"

FILE_PATH = "#{Rails.root}/files"

namespace :sepomex do
  desc "Retrieves ZIP Codes from Sepomex's webpage and unzips the downloaded zip into a folder"
  task :update_csv do
    # Cleans the previous .xls file
    clean_up("#{FILE_PATH}/CPdescarga.xls")

    download_file

    unzip_file
  end
end

private

def download_file
  # Check with Vov on how to set up a chromium container so the script can execute
  browser = Ferrum::Browser.new(
    slowmo: 1,
    save_path: FILE_PATH,
    browser_options: { 'no-sandbox': nil }
  )
  # Goto SEPEMEX's download page
  browser.go_to('https://www.correosdemexico.gob.mx/SSLServicios/ConsultaCP/CodigoPostal_Exportar.aspx')
  # Get SEPEMEX's input button and click it
  # Currently: input id = 'btnDescarga'
  browser.at_css('#btnDescarga').click
  # Waits for the download to finish
  sleep 20
  # Closes browser
  browser.quit
end

def unzip_file
  # Access to the .zip file
  Zip::File.open('CPdescargaxls.zip') do |zf|
    # Read the .zip file's content
    zf.each do |f|
      # Extracts the contents
      f.extract(f.name)
    end
  end

  # Cleanup of the .zip file
  clean_up("#{FILE_PATH}/CPdescargaxls.zip")
end

def clean_up(file)
  File.delete(file) if File.exist?(file)
end
