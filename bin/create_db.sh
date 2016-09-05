sudo -u postgres psql <<EOF
CREATE ROLE bullseye WITH CREATEDB LOGIN PASSWORD 'bullseye';
CREATE DATABASE dev_bullseye WITH OWNER bullseye;
CREATE DATABASE test_bullseye WITH OWNER bullseye;
EOF
