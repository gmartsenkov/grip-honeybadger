require "grip"
require "honeybadger"

class Grip::Handlers::Honeybadger
  include HTTP::Handler

  def call(context : HTTP::Server::Context) : HTTP::Server::Context
    call_next(context)
    context
  rescue exception
    Honeybadger.notify(exception)
    context.response.status_code = 500
    context.exception = exception
    context

    {% if flag?(:hideAllExceptions) %}
      context.response.print("500 Internal Server Error")
    {% else %}
      context.response.headers.merge!({"Content-Type" => "text/html; charset=UTF-8"})
      context.response.print(Grip::Minuscule::ExceptionPage.for_runtime_exception(context, exception).to_s)
    {% end %}

    context
  end
end
