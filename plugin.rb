# name: Wechat QRconnect
# about: Authenticate with discourse with Wechat QRconnect.
# version: 0.1
# author: mooosu
# url: https://github.com/mooosu/wechat_qrconnect

require 'omniauth/strategies/oauth2'

class OmniAuth::Strategies::WechatQRconnect < OmniAuth::Strategies::OAuth2
  option :name, "wechat_qrconnect"

  option :client_options, {
    :site => 'https://open.weixin.qq.com',
    :authorize_url => 'https://open.weixin.qq.com/connect/qrconnect',
    :token_url => 'https://api.weixin.qq.com/sns/oauth2/access_token'
  }

  uid do
    @uid ||= begin
      access_token.params['openid']
    end
  end

  info do
    {
      :nickname => raw_info['nickname'],
      :name => raw_info['nickname'],
      :image => raw_info['headimgurl'],
    }
  end

  extra do
    {
      :raw_info => raw_info
    }
  end

  def raw_info
    @raw_info ||= begin
      response = client.request(:get, "https://api.weixin.qq.com/sns/userinfo", :params => {
        :openid => uid,
        :access_token => access_token.token
      }, :parse => :json)
      response.parsed
    end
  end

  # customization
  def authorize_params
    super.tap do |params|
      params[:appid] = options.client_id
      params[:scope] = 'snsapi_login'
    end
  end

  def token_params
    super.tap do |params|
      params[:appid] = options.client_id
      params[:secret] = options.client_secret
      params[:parse] = :json
      params.delete('client_id')
      params.delete('client_secret')
    end
  end
end

OmniAuth.config.add_camelization('wechat_qrconnect', 'WechatQRconnect')

# Discourse plugin
class WechatQRconnectAuthenticator < ::Auth::Authenticator

  def name
    'wechat_qrconnect'
  end

  def after_authenticate(auth_token)
    result = Auth::Result.new

    data = auth_token[:info]
    raw_info = auth_token[:extra][:raw_info]
    name = data['nickname']
    username = data['name']
    wechat_uid = auth_token[:uid]

    current_info = ::PluginStore.get('wechat_qrconnect', "wechat_uid_#{wechat_uid}")

    result.user =
      if current_info
        User.where(id: current_info[:user_id]).first
      end

    result.name = name
    result.username = username
    result.extra_data = { wechat_uid: wechat_uid, raw_info: raw_info }

    result
  end

  def after_create_account(user, auth)
    wechat_uid = auth[:extra_data][:wechat_uid]
    ::PluginStore.set('wechat_qrconnect', "wechat_uid_#{wechat_uid}", {user_id: user.id})
  end

  def register_middleware(omniauth)
    omniauth.provider :wechat_qrconnect, :setup => lambda { |env|
      strategy = env['omniauth.strategy']
      strategy.options[:client_id] = SiteSetting.wechat_qrconnect_client_id
      strategy.options[:client_secret] = SiteSetting.wechat_qrconnect_client_secret
    }
  end
end

auth_provider :frame_width => 760,
              :frame_height => 500,
              :authenticator => WechatQRconnectAuthenticator.new,
              :background_color => '#51b7ec'

register_css <<EOF
.btn-social.wechat_qrconnect:before {
  font-family: FontAwesome;
  content: "\\f1d7";
}
EOF
