defmodule ExcmsCoreWeb.AuthorizeViewHelpers do
  use ExcmsCoreWeb.AuthorizeViewHelpersBase,
    lazy_can_path: &ExcmsCoreWeb.RouteAuthorizer.can_path?/3
end
