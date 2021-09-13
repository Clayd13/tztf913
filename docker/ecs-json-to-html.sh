#!/bin/bash
  

# start of Creating ec2 tag "data creation"
instanceId=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
data_creaion=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep pendingTime | awk -F\" '{print $4}')

aws ec2 create-tags --resources "$instanceId" --tags Key=Data_creation,Value="$data_creaion" --region "$region"
# end of Creating ec2 tag "data creation"


# Start creating script convert EC2 Tags from json to html 

cat<<EOFile > json-to-html-script.sh
#!/bin/bash

cat<<EOF
<!DOCTYPE html>
<html>
  <head>
    <title>Tags of EC2</title>
  </head>
  <body>
EOF

 

cat - | jq -r '.Tags | map(
          "<tr><td>" + .Key
        + "</td><td>" + .Value
        + "</td></tr>")
      | ["<table border=\"1px solid black\"><caption>Tags of EC2</caption> <tr><td>Tag</td><td>Value</td>"] + . + ["</tr></table>"] | .[]'


cat<<EOF
  </body>
</html>
EOF
EOFile

# End creating script convert EC2 Tags from json to html

chmod +x ./json-to-html-script.sh

# Filling html table by EC2 tags
aws ec2 describe-tags --filters Name=resource-id,Values="$instanceId" --region="$region" | ./json-to-html-script.sh |sudo tee /var/www/html/index.html

exec httpd -DFOREGROUND

