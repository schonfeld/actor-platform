rm -rf /Users/michaelschonfeld/dev/sexywaffles/actor-bootstrap/app-ios/Pods/ActorSDK-iOS/Frameworks/ActorSDK.framework
rm -rf /Users/michaelschonfeld/dev/sexywaffles/actor-bootstrap/app-ios/Pods/ActorSDK-iOS/Frameworks/ActorSDK.framework.dSYM
cp -a /x/actor-sdk/sdk-core-ios/build/Output/ActorSDK.framework /Users/michaelschonfeld/dev/sexywaffles/actor-bootstrap/app-ios/Pods/ActorSDK-iOS/Frameworks/
cp -a /x/actor-sdk/sdk-core-ios/build/Output/ActorSDK.framework.dSYM /Users/michaelschonfeld/dev/sexywaffles/actor-bootstrap/app-ios/Pods/ActorSDK-iOS/Frameworks/
echo "Latest framework copied!"