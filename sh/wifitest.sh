#!/bin/bash

typeset i=1
while true; do
echo "======= $i $(date) ============" >> log1
curl 'https://bug.oraclecorp.com/pls/bug/webbug_reports.my_open_bugs' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: en-US,en;q=0.8,zh-CN;q=0.6,zh;q=0.4' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.97 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: https://login.oracle.com/mysso/signon.jsp' -H 'Cookie: OHS-bug.oraclecorp.com-443=4AC1B8704EDF2C783B2FA0FADF3D4A0D7B9B25F78FDE12FF4F6C9D93260FEC3B81E69F36017BE9EFA2FF09E6579B8E691C1CB8C93A40FC5A0E15C1033766D89DD323244329DFD7BA3A0308907726AE8E571FBF2C8C7071321992340B1A1811E36607E2E6E06B552BDDEAB9CEDD104B5575660059A5C4229CA67F9E28F88800ECD0BE2C03CE39761C817EC811F4142921CF7506F7F3A2B3575C8465585AFE8C15BAD128D66D435562F766D5E7DCFD1FBEF973CCA0054100110FE19D3CDF1D73B9F3CCF6645F7157DA5012A043C3ACD60EC2851CC89B91F94ECDC1246074D334C508AE9194C2E1E6BE58AA8B937E8D90CE45290ADAB14452E3~' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' --compressed -v | tee -a log1
((i=i+1))
echo "============== begin to sleep at $(date) =======" | tee -a log1
sleep $((60*67))
done

