# name: Salesforce.com
# about: Authenticate with discourse with Salesforce.com
# version: 1.0.5
# author: Akash Kingre, Relecotech, Inc.

gem 'omniauth-salesforce', '1.0.5'

class SalesForceAuthenticator < ::Auth::Authenticator
  
  CLIENT_ID = '3MVG9xOCXq4ID1uGenaaD_8KBjd0O9KOi.C.u6q3myzab1zKtlzvNWJKHGkMOH3dGMElkJDiDONzjM7ZSO3iH'
  CLIENT_SECRET = '5080884079483736481'
  def name
    'salesforce'
  end

  def after_authenticate(auth_token)
    result = Auth::Result.new

    # grap the info we need from omni auth
    data = auth_token[:info]
    raw_info = auth_token["extra"]["raw_info"]
    name = data["name"]
    li_uid = auth_token["uid"]

    # plugin specific data storage
    current_info = ::PluginStore.get("li", "li_uid_#{li_uid}")

    result.user =
      if current_info
        User.where(id: current_info[:user_id]).first
      end

    result.name = name
    result.extra_data = { li_uid: li_uid }

    result
  end

  def after_create_account(user, auth)
    data = auth[:extra_data]
    ::PluginStore.set("li", "li_uid_#{data[:li_uid]}", {user_id: user.id })
  end

  def register_middleware(omniauth)
    omniauth.provider :salesforce,
     CLIENT_ID,
     CLIENT_SECRET
  end
end


auth_provider :title => 'with salesforce',
    :message => 'Log in via Salesforce (Make sure pop up blockers are not enabled).',
    :frame_width => 920,
    :frame_height => 800,
    :authenticator => SalesForceAuthenticator.new


# We ship with zocial, it may have an icon you like http://zocial.smcllns.com/sample.html
#  in our current case we have an icon for li
register_css <<CSS

.btn-social.salesforce {
  background: #46698f;
}

.btn-social.salesforce:before {
  content: "SF";
}

CSS
