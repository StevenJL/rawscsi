module Rawscsi
  module Stringifier
    module Encode
      def encode(str)
        # URI and CGI.escape don't quite work here
        # For example, I need blank space as %20, but they encode it as +
        # So I have to write my own
        str.gsub(' ', '%20').gsub("'", '%27').gsub("[", '%5B').gsub("]",'%5D').gsub("{", '%7B').gsub("}", '%7D')
      end
    end
  end
end

