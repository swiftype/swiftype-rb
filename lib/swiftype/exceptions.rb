module Swiftype
  class ClientException < StandardError; end
  class NonExistentRecord < ClientException; end
  class RecordAlreadyExists < ClientException; end
  class InvalidCredentials < ClientException; end
  class BadRequest < ClientException; end
  class Forbidden < ClientException; end
  class UnexpectedHTTPException < ClientException; end
end
