echo exit | sqlplus cui102@csora/jupYgBdG @drop.sql >/dev/null
echo exit | sqlplus cui102@csora/jupYgBdG @create.sql >/dev/null
echo exit | sqlplus cui102@csora/jupYgBdG @init.sql >/dev/null

javac -cp .:ojdbc8.jar Project3.java
java -cp .:ojdbc8.jar Project3 input.txt output.txt
