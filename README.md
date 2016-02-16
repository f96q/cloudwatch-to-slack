# cloudwatch-to-slack

## setup

```
cp .env.example .env
bundle exec ruby setup.rb <name> <web_hook_url> <slack_channel>
```

## example

```
bundle exec ruby setup.rb 'alert' 'hooks.slack.com/services/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' '#alert'
```
