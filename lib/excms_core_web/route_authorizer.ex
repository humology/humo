defmodule ExcmsCoreWeb.RouteAuthorizer do
  use ExcmsCoreWeb.RouteAuthorizer.Macro,
    lazy_router: &ExcmsCoreWeb.router/0,
    user_extractor: ExcmsCoreWeb.UserExtractor
end
