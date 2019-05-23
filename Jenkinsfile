def label = 'debsource-reco'
def commitSHA
podTemplate(label: label,
        containers: [
            containerTemplate(ttyEnabled: true, command: 'cat', envVars: [envVar(key: 'TZ', value: 'Asia/Taipei')], image: '192.168.15.59/grain5/ros-base:pr228', name: 'pr228'),
        ]
        ) {
        node(label) {
                    
            container('pr228') {
                stage('Pull Source Code'){
                    withCredentials([usernamePassword(credentialsId: '93cd491a-412b-41dd-b613-891fc6bd8a88', 
                        usernameVariable: 'GITHUB_ACCOUNT',passwordVariable:'GITHUB_PASSWORD')]){
                        sh 'git config --global credential.helper cache'
                        sh '''git clone  --branch master --depth=1 https://"$GITHUB_ACCOUNT":"$GITHUB_PASSWORD"@github.com/aeolusbot/debsource-reco.git'''
                        dir("debsource-reco"){ 
                            sh '''git clone --branch master --depth=1 https://"$GITHUB_ACCOUNT":"$GITHUB_PASSWORD"@github.com/aeolusbot/object_tracer.git ''' +
                               '''&& cd object_tracer &&  sed -i \'s|git@github.com:aeolusbot|https://github.com/aeolusbot|\' .gitmodules && git submodule init && git submodule update --remote'''   
                        }
                    }     
                }
                stage('Setup Debsource'){
                    dir('aptsource') {
                        git changelog: false, credentialsId: '93cd491a-412b-41dd-b613-891fc6bd8a88', poll: false, url: 'https://github.com/aeolusbot/docker-images.git'
                    }
                    sh 'cp -r aptsource/src/xenial/apt/preferences.d /etc/apt/'
                    sh 'cp -r aptsource/src/xenial/apt/sources.list.d /etc/apt/'
                    sh 'cp -r aptsource/src/xenial/apt/trusted.gpg.d /etc/apt/'
                    sh 'apt-get update && apt-get install -y nuitka devscripts build-essential fakeroot ros-kinetic-opencv3 libopencv-dev libopenblas-base debhelper cython'
                    sh 'apt install -y libopenblas-dev'
                    
                }            
                stage('Build Debsource'){
                    sh 'cp -r debsource-reco/object_tracer/reco_model/* debsource-reco/model/'
                    dir("debsource-reco") {
                        sh 'cd object_tracer/libs/dlf &&. ./script/env.sh && python setup.py'
                        sh 'rosdep init && rosdep update'
                        sh './build.bash'
                        //Uploading *.deb
                    }
                }
            }
        }
    }
