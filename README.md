# Wechat qrconnect plugin for Discourse / Discourse 微信二维码登陆验证插件

Authenticate with discourse with wechat qrconnect.

通过 微信二维码 互联登陆 Discourse。

## 为高效运维论坛编写

论坛地址: http://discuss.greatops.net/

## Register website application / 创建网站应用

1. 登录 [Wechat QRconnect](https://open.weixin.qq.com/)，注册填写相关信息。
2. 进入`管理中心`，点击`网站应用`，点击`创建网站应用`。
3. 根据向导完成注册。

> **Note:**
> 目前微信只受理公司申请，也即需要提供有营业执照等


## Installation / 安装

#### 与Discourse同步安装
在 `app.yml` 的

    hooks:
      after_code:
        - exec:
            cd: $home/plugins
            cmd:
              - mkdir -p plugins
              - git clone https://github.com/discourse/docker_manager.git

在 `- git clone https://github.com/discourse/docker_manager.git` 后添加：

    - git clone https://github.com/mooosu/wechat_qrconnect

#### 或者对于已经部署过的系统可以使用下面命令

```bash
rake plugin:install repo=https://github.com/mooosu/wechat_qrconnect.git
rake assets:precompile
```
重启Rails。


## Usage / 使用

Go to Site Settings's login category, fill in the client id and client secret.

进入站点设置的登录分类，填写 client id 和 client serect。

## Changelog

Current version: 0.1.0
