defmodule ExcmsCoreWeb.RouteAuthorizer do
  use ExcmsCoreWeb.RouteAuthorizerBase,
    lazy_web_router: &ExcmsCoreWeb.router/0,
    user_extractor: ExcmsCoreWeb.UserExtractor
end
