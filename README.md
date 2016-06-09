# cloudwatch-to-slack

## setup

### policy

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1443036478000",
            "Effect": "Allow",
            "Action": [
                "kms:CreateKey",
                "kms:CreateAlias",
                "kms:Encrypt",
                "iam:CreateRole",
                "iam:PassRole",
                "iam:AttachRolePolicy",
                "iam:PutRolePolicy",
                "lambda:CreateFunction"
            ],
            "Resource": "*"
        }
    ]
}
```

### command

```
cp .env.example .env
bundle exec ruby setup.rb <name> <web_hook_url> <slack_channel>
```

## example

```
bundle exec ruby setup.rb 'alerm-name-cloudwatch-to-slack-staging' 'hooks.slack.com/services/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' '#alert-staging'
```
