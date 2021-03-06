module Oncotrunk
  def self.with_friendly_errors
    yield
  rescue Oncotrunk::OncotrunkError => e
    Oncotrunk.ui.error e.message
    exit e.status_code
  rescue Interrupt => e
    Oncotrunk.ui.error "\nQuitting..."
    exit 1
  rescue SystemExit => e
    exit e.status
  rescue Exception => e
    Oncotrunk.ui.error "Oncotrunk crashed!"
    Oncotrunk.ui.trace e
    raise e
  end
end
