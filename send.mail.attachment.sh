#!/bin/bash

# универсальный способ создания письма с аттачем.
# дополнительный софт не требуется.
# создается тело письма со всеми заголовками, включая from (sendmail -t) или без него.
# http://backreference.org/2013/05/22/send-email-with-attachments-from-script-or-command-line/
# some variables
# refactoring the script such that all these values are
# passed from the outside as arguments should be easy

get_mimetype(){
  # warning: assumes that the passed file exists
  file --mime-type "$1" | sed 's/.*: //' 
}

boundary="ZZ_/afg6432dfgkl.94531q"
#from="user@${hostname -f}"
[[ -z $to ]] && to="user@domain.com"
[[ -z $subject ]] && subject="Some fancy title"
[[ -z $body ]] && body="This is the body of our email"
declare -a attachments
[[ -z $attachments ]] && attachments=( "file01.txt" "file02.zip")


# Build headers
{

printf '%s\n' "From: $from
To: $to
Subject: $subject
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=\"$boundary\"

--${boundary}
Content-Type: text/plain; charset=\"US-ASCII\"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

$body
"
 
# now loop over the attachments, guess the type
# and produce the corresponding part, encoded base64
for file in "${attachments[@]}"; do

  [ ! -f "$file" ] && echo "Warning: attachment $file not found, skipping" >&2 && continue

  mimetype=$(get_mimetype "$file") 
 
  printf '%s\n' "--${boundary}
Content-Type: $mimetype
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=\"$file\"
"
 
  base64 "$file"
  echo
done
 
# print last boundary with closing --
printf '%s\n' "--${boundary}--"
 
}  | sendmail -t -oi   # one may also use -f here to set the envelope-from
# | sendmail -oi   # one may also use -f here to set the envelope-from