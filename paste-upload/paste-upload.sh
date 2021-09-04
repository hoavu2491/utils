
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

#export sc_token=eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIxMDAxMDAxNjYiLCJpYXQiOjE2MzA2NDIzNDMsImV4cCI6MTYzMDgxNTE0MywiaXNzIjoiaHR0cHM6Ly90aWtpLnZuIiwiY3VzdG9tZXJfaWQiOiIxMDAxMDAxNjYiLCJjbGllbnRfaWQiOiJ0aWtpLXNzbyIsInNjb3BlIjoic3NvIn0.J6uSStic8O68J5ZQdoI4rCrG8dAQpMWry8ppF_8J1_zexKUU_xieOLTuh58QV81_xNkjWjSTJwDkZX4Z66PoSZ3wkuUK9sVqP047ZA7PKCwVFwIVyBdnhcQF1fIrJSxQBK3y4J6GrWIEiljhjGTpanVlcXRnn4AD59a932qgnGaSxH9ILJ7U7xSOkscOH3KfOsgU6PRfRdEcnKUDWLmQTy6T3NbFMzwPuIfbr4ueTdsvDt16y886ZUOmkpJcqIpMTHG9kE1VS22FcGkvFhUIvYPDDjPE_ZzsOGAJaal5gW8MbugH_Lx-f_vm5A7DKKxLSv2rlh3yavyyK9Qv1xLa_vzWd63JdKPY4l6hbhZNtYD0hnL2ztUQXGs8o0Z-2weQIH6o53YZqig5SjmY_Eji8TKvvyDmn0YQqt-EUajYx1oBdaJlR5cDwzZcv-fvaq4eMEbGbojfNIEBDR7SaOxDQwnL-FFu4WQhFcGOFaWeagAQtpELPADByZ703RbGijY_xR4SwFiuJ3S6o-kihHwsWSiIm5_jaZ4d-DOmUmfW3_alXR9Ds9RbRQvItd3pfT7Nlr0awPF5lyIrH3Q3VOg3Z4STjtxATuElmF9IDbldfw0tfRxmIcNYea3-5tzdea7NfBj-cPEpWupaV-OhNugC7cjsluiseHeN3umvFyvNtYE
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