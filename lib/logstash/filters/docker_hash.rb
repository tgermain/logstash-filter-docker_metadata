require 'hashie'

class DockerHash < Hash

  include Hashie::Extensions::IndifferentAccess

end
