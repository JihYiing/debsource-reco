from object_tracer.core.dlf_repository import FUNC2MODEL
import os
import shutil


parent_path=os.path.dirname(os.path.realpath(__file__))
dlf_source = os.path.dirname(parent_path)+"/debsource-reco/object_tracer/libs/dlf/inference/model"

print FUNC2MODEL
output = parent_path+"/model/dlf"
print dlf_source
for key in FUNC2MODEL:
    framework = FUNC2MODEL[key][0]
    model_name = FUNC2MODEL[key][1]
    src_path =  dlf_source+"/"+framework+"/"+model_name
    dest = output+"/"+framework+"/"+model_name
    #print src_path
    #print dest
    if not os.path.exists(dest):
#        os.makedirs(dest)
        print "copy dest:"+dest
        shutil.copytree(src_path,dest)


#print parent_path+"/deep_learning_framework/inference/model"
#print os.path.exists(parent_path+"/deep_learning_framework/inference/model")
