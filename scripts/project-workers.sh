#! /bin/bash
# All workerss will run in screen, so if you haven't screen, please install it using sudo yum install screen

# First we need to enable httpd, postgresql, gearman, memcache, redis, solr
# some code will be here...

# Sure if user in project directory
echo Are you in project directory? [yes/no]
read answer
if [ "$answer" != 'yes' ]
then
	echo Please follow to project directory and try again
	exit 1
fi

projectDir="`pwd`"

# 1. Activation of shard worker 1 in "s1" screen
screen -dmS s1
screen -S s1 -p 0 -X stuff "cd $projectDir^M"
screen -S s1 -p 0 -X stuff 'app/console doctrine:sharding:worker:shard^M'

# 2. Activation of shard worker 2 in "s2" screen
screen -dmS s2
screen -S s2 -p 0 -X stuff "cd $projectDir^M"
screen -S s2 -p 0 -X stuff 'app/console doctrine:sharding:worker:shard^M'

# 3. Activation of message service in "ms" screen
screen -dmS ms
screen -S m1 -p 0 -X stuff "cd $projectDir^M"
screen -S m1 -p 0 -X stuff 'app/console archer:worker:messages:service^M'

# 4. Activation of warmup cache worker in "warmup" screen
screen -dmS warmup
screen -S m2 -p 0 -X stuff "cd $projectDir^M"
screen -S m2 -p 0 -X stuff 'app/console archer:worker:messages:warmup-cache^M'

# 5. Activation of user import worker in "user-import" screen
screen -dmS user-import
screen -S import -p 0 -X stuff "cd $projectDir^M"
screen -S import -p 0 -X stuff 'app/console archer:worker:import:users^M'

# 6. Activation of cache accessor worker in "ca" screen
screen -dmS ca
screen -S ca -p 0 -X stuff "cd $projectDir^M"
screen -S ca -p 0 -X stuff 'app/console archer:worker:cache-accessor^M'

# 7. Activation of nodejs in "nodejs" screen
screen -dmS nodejs
screen -S nodejs -p 0 -X stuff "cd $projectDir/nodejs^M"
screen -S nodejs -p 0 -X stuff 'node app.js^M'

exit 0
