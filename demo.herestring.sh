#!/usr/bin/env bash

string='Hello World'

echo '# Here strings'
# here strings
wc -w <<<${string}

# the same. shell pipe
echo ${string} | wc -w 


echo 'number interfaces:'
wc -w <<<$(ip -4 -br addr | cut -d' ' -f1 | grep -v 'lo')

echo '# Here document'
# here document
echo
echo 'cat <<EOF'
cat <<EOF
Hello
World
$string
EOF

echo -n 'number words:'
wc -w <<EOF
Hello
World
$string
EOF
echo 
# supress expanding variable
echo 'cat <<'\'EOF\'
cat <<'EOF'
Hello
World
$string
EOF

echo -n 'number words:'
wc -w <<'EOF'
Hello
World
$string
EOF


# multiline comment
<<'EOF'
Hello, World!
$string
EOF

# multiline comment
: '
Hello, World!
$string
'

