if [ $# -lt 3 ]
then
    echo "usage: $0 from_sym to_sym"
    exit 1
fi
cat > /tmp/sed.script <<EOF
/[^a-zA-Z0-9]*$1([^a-zA-Z0-9_]+|$)/ {
s/$1/$2/
}
EOF

shift
shift

sed -E -i -f /tmp/sed.script $@



