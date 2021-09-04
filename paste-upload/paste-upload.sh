
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

if ! command -v pngpaste &> /dev/null
then
    echo "pngpaste is not installed, running brew install pngpaste"
    brew install pngpaste
fi

if ! command -v jq &> /dev/null
then
    echo "jq is not installed, running brew install jq"
    brew install jq
fi

TOKEN=$sc_token

if [ -z $TOKEN ]
then
    echo "${red}No Token, please get token from Seller Center and run 'export sc_token={token_from_seller_center}'${reset}"
    exit 1
fi

Email=$(curl -s 'https://sellercenter.tiki.vn/api/user?include=permissions,roles' \
  --header "Authorization: Bearer $TOKEN" \
  --compressed | jq -r '.email')

echo "Email: ${green}${Email}${reset}"

if [ $Email == "null" ]
then
    echo "${red}Invalid User or token expired, exit${reset}"
    echo "${red}Please get token from Seller Center and run 'export sc_token={token_from_seller_center}'${reset}"
    exit 1
fi

pngpaste /tmp/paste.png

if [ $? -eq 0 ]
then
    echo "${green}Created image file from Clipboard(/tmp/paste.png), Starting upload${reset}"
else
    echo "${red}No Image in the clipboard, exit${reset}"
    exit 1
fi

Response=$(curl -s --location --request POST 'https://api-sellercenter.tiki.vn/titan/v1/uploads' \
--header "Authorization: Bearer $TOKEN" \
--form 'files=@"/tmp/paste.png"')

Url=$(echo $Response | jq -r '.data[0].url')

#echo "$Response"
echo "Uploaded Image Url: $Url"

if [ $Url == "null" ]
then
    echo "${red}No image uploaded, exit${reset}"
    exit 1
else
    echo "$Url" | pbcopy
    echo "${green}Copied image url to clipboard${reset}"
    exit 0
fi