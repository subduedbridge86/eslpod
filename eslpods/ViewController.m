#import "ViewController.h"

@interface ViewController()
@property float ipodVol;
//@property float speakerVol;
//@property float systemVol;
@property long songCount;
@property int repeatCount;
@property float getSecond;
@property int second;
@property int minute;
@property int maxsecond;
@property int maxminute;
@property int playback;
@property CMTime tm;
@property int senderval;
@property int maxback;
@property BOOL miccount;
@property float newValue;
@property float oldValue;
@property BOOL seekPlaying;
@property BOOL headphoneConnect;
@property NSString* ipodVoltext;
@property BOOL addFlag;

@property MPMusicPlayerController *player;

@property NSDictionary *songinfo;

@property AVAudioSessionPortDescription *desc;

//@property AVQueuePlayer *avPlayer;
@property NSURL *url;
@property AVPlayerItem *playerItem;
@property MPMediaItemCollection *mediaItemCollection2;
//@property NSNotificationCenter *notification;
@property NSMutableArray *nameData;
@property NSData *mediaitemData;
@property NSTimer *timer;
@property NSString *maxtimelabelstr;
@property NSString *timestr;
@property NSString *name1,*name2;

@property ESLpod *mypod,*mypod2;
//@property NSArray *mypodArray;

@property (weak, nonatomic) IBOutlet UITableView *songList;
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (weak, nonatomic) IBOutlet UILabel *albumlabel;
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UILabel *maxtimelabel;
@property (weak, nonatomic) IBOutlet UISlider *autoseek;
@property (weak, nonatomic) IBOutlet UILabel *musicIcon;

@property (weak, nonatomic) IBOutlet UIButton *playImage;
@property (weak, nonatomic) IBOutlet UIButton *micimage;
@property (weak, nonatomic) IBOutlet UIButton *repeatImage;


@property (weak, nonatomic) IBOutlet UILabel *ipodVolLabel;
@property (weak, nonatomic) IBOutlet UILabel *fbVolLabel;
@property (weak, nonatomic) IBOutlet UILabel *delaytimeLabel;


@property (weak, nonatomic) IBOutlet UISlider *ipodvol;
@property (weak, nonatomic) IBOutlet UISlider *feedvol;
@property (weak, nonatomic) IBOutlet UISlider *delaytime;


@end

@implementation ViewController


#define feedTimes 3
#define IPOD_VOL 1000
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

-(void)addRemoteCommandCenter{
    MPRemoteCommandCenter *rcc = [MPRemoteCommandCenter sharedCommandCenter];
    [rcc.togglePlayPauseCommand addTarget:self action:@selector(avtoggle:)];
    [rcc.playCommand addTarget:self action:@selector(avplay:)];
    [rcc.pauseCommand addTarget:self action:@selector(avpause:)];
    [rcc.nextTrackCommand addTarget:self action:@selector(avnextTrack:)];
    [rcc.previousTrackCommand addTarget:self action:@selector(avprevTrack:)];
}

- (void)avtoggle:(MPRemoteCommandEvent*)event{
    [self pushPlay];
    [self miconoff];
    
}

- (void)avplay:(MPRemoteCommandEvent*)event{
    [_playImage setImage : [ UIImage imageNamed : @"pauseClear.png" ] forState : UIControlStateNormal];
    [avPlayer play];
    _seekPlaying=YES;
    
    [_mypod feed];
    [_mypod bufferSet];
    [_mypod mixUnitvol];
    [_mypod delayUnittime];
    //[_mypod2 audioSession];
    [_mypod2 feed];
    [_mypod2 bufferSet];
    [_mypod2 mixUnitvol];
    [_mypod2 delayUnittime];
    _feedvol.minimumTrackTintColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    _fbVolLabel.textColor=[UIColor blackColor];
    _delaytime.minimumTrackTintColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    _delaytimeLabel.textColor=[UIColor blackColor];
    [_micimage setImage : [ UIImage imageNamed : @"miconbutton.png" ] forState : UIControlStateNormal];
    _miccount=YES;
}

- (void)avpause:(MPRemoteCommandEvent*)event{
    [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
    [avPlayer pause];
    _seekPlaying=NO;
    
    [_mypod auClose];
    [_mypod2 auClose];
    _feedvol.minimumTrackTintColor=[UIColor lightGrayColor];
    _fbVolLabel.textColor=[UIColor lightGrayColor];
    _delaytime.minimumTrackTintColor=[UIColor lightGrayColor];
    _delaytimeLabel.textColor=[UIColor lightGrayColor];
    [_micimage setImage : [ UIImage imageNamed : @"micoffbutton.png" ] forState : UIControlStateNormal];
    _miccount=NO;
}

- (void)avnextTrack:(MPRemoteCommandEvent*)event{
    [self nextsong];
}

- (void)avprevTrack:(MPRemoteCommandEvent*)event{
    [self backsong];
}

- (void)viewDidLoad
{
    self.title = @"";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRow:)];
    self.navigationItem.leftBarButtonItem = anotherButton;
    
    _ipodVol=0.0;
    //_systemVol=0;書いたらスライダーの色が変わらなくなる
    _songCount=0;
    _miccount=YES;
    _addFlag=NO;
    
    
    [super viewDidLoad];
    UIImage *imageForThumb = [UIImage imageNamed:@"slider.png"];
    [_autoseek setThumbImage:imageForThumb forState:UIControlStateNormal];
    [_autoseek setThumbImage:imageForThumb forState:UIControlStateHighlighted];
    [self.view addSubview:_autoseek];
    
    _songList.delegate = self;
    _songList.dataSource = self;
    
    _mypod=[[ESLpod alloc]init];
    [_mypod audioSession];
    
    
    _mypod2=[[ESLpod alloc]init];
    [_mypod2 audioSession];
    
    
    _player = [MPMusicPlayerController applicationMusicPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeAudioSessionRoute:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(telephoneObserver:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(avPlayDidFinish:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:avPlayer];
    ///前回のスライダー値反映
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    
    
    
    _mypod.feedVol=[ud floatForKey:@"feedvol"];
    _mypod2.feedVol=[ud floatForKey:@"feedvol"];
    
    
    
    NSString *fbVoltext = [NSString stringWithFormat:@"%.0f", _mypod.feedVol*100];
    _fbVolLabel.text=fbVoltext;
    _feedvol.value=_mypod.feedVol;
    
    _mypod.delayTime=[ud floatForKey:@"delayTime"];
    _mypod2.delayTime=[ud floatForKey:@"delayTime"];
    
    
    
    NSString *delaytimetext = [NSString stringWithFormat:@"%.01f", _mypod.delayTime*2];
    _delaytimeLabel.text=delaytimetext;
    _delaytime.value=_mypod.delayTime;
    
    _mediaitemData=[ud objectForKey:@"_mediaitemData"];
    _songCount=[ud floatForKey:@"songCount"];
    
    @try{
        _mediaItemCollection2 = [NSKeyedUnarchiver unarchiveObjectWithData:_mediaitemData];
        if (_mediaItemCollection2.count>=1) {
            MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:_songCount];
            _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
            _playerItem = [[AVPlayerItem alloc] initWithURL:_url];
            avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
            [self songtext];
            
            _nameData=[[NSMutableArray alloc]init];
            for (int i = 0;i < _mediaItemCollection2.count; i++) {
                MPMediaItem *nameitem1=[_mediaItemCollection2.items objectAtIndex:i];
                
                _name1=[nameitem1 valueForProperty:MPMediaItemPropertyTitle];
                _name2=[[nameitem1 valueForProperty:MPMediaItemPropertyAlbumTrackNumber]stringValue];
                
                //NSString* str1 = [NSString stringWithFormat: @"%4@", _name2];
                //NSLog(@"%@",str1);
                if (_name1!=nil) {
                    [_nameData addObject:_name1];
                }
                //NSLog(@"%d曲目　%@",i,[_nameData objectAtIndex:i]);
            }
        }
    }
    @catch(NSException *ex){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"曲情報が変更されました" message:@"曲を再選択して下さい" delegate:self cancelButtonTitle:@"OK！" otherButtonTitles:nil, nil];
        [alert show];
        avPlayer=nil;
        _timelabel.text=[NSString stringWithFormat:@"00:00"];
        _maxtimelabel.text=[NSString stringWithFormat:@"-00:00"];
        _titlelabel.text=[NSString stringWithFormat:@"曲が選択されていません"];
    }
    
    
    [self addRemoteCommandCenter];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    
    [_songList reloadData];
    [self AutoScroll];
    
    avPlayer.volume=_ipodVol;
    [self startTimer];
    
    _repeatCount=[ud floatForKey:@"repeatCount"];
    if (_repeatCount==1) {//1曲
        [_repeatImage setImage : [ UIImage imageNamed : @"repeat11.png" ] forState : UIControlStateNormal];
    }else if (_repeatCount==0){//all
        [_repeatImage setImage : [ UIImage imageNamed : @"repeat0.png" ] forState : UIControlStateNormal];
    }else{//non
        [_repeatImage setImage : [ UIImage imageNamed : @"repeata.png" ] forState : UIControlStateNormal];
    }

    NSArray *out = _mypod->session.currentRoute.outputs;
    _desc = [out lastObject];
    //NSLog(@"%@",_desc);
    if ([_desc.portType isEqual:AVAudioSessionPortHeadphones])
    {
        NSLog(@"起動時イヤホン接続中");
        [self ipodLabelDefault];
        [_mypod feed];
        [_mypod bufferSet];
        [_mypod mixUnitvol];
        [_mypod delayUnittime];
        [_mypod2 feed];
        [_mypod2 bufferSet];
        [_mypod2 mixUnitvol];
        [_mypod2 delayUnittime];
        [_mypod mixUnitvol];
        [_mypod2 mixUnitvol];
        [_mypod delayUnittime];
        [_mypod2 delayUnittime];
        _feedvol.minimumTrackTintColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        _fbVolLabel.textColor=[UIColor blackColor];
        _delaytime.minimumTrackTintColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        _delaytimeLabel.textColor=[UIColor blackColor];
        
        [_micimage setImage : [ UIImage imageNamed : @"miconbutton.png" ] forState : UIControlStateNormal];
        _miccount=YES;
    }else{
        NSLog(@"起動時イヤホン未接続");
        [self ipodLabelRed];
        [_mypod auClose];
        [_mypod2 auClose];
        _feedvol.minimumTrackTintColor=[UIColor lightGrayColor];
        _fbVolLabel.textColor=[UIColor lightGrayColor];
        _delaytime.minimumTrackTintColor=[UIColor lightGrayColor];
        _delaytimeLabel.textColor=[UIColor lightGrayColor];
        
        [_micimage setImage : [ UIImage imageNamed : @"micoffbutton.png" ] forState : UIControlStateNormal];
        _miccount=NO;
    }
    
    avPlayer.volume=_ipodVol;
    
    _ipodVolLabel.text=_ipodVoltext;
    _ipodvol.value=_ipodVol;
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [_songList setEditing:editing animated:YES];
    if (editing) {
        //            UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
        //                                                                                       target:self action:@selector(addRow:)] ;
        //            [self.navigationItem setLeftBarButtonItem:addButton animated:YES]; // 追加ボタンを表示します。
    } else {
        //            [self.navigationItem setLeftBarButtonItem:nil animated:YES]; // 追加ボタンを非表示にします。
        NSIndexPath* indexPath2 = [NSIndexPath indexPathForRow:_songCount inSection:0];
        [_songList selectRowAtIndexPath:indexPath2 animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)addRow:(id)sender {
    if (_name1!=nil) {
        _addFlag=YES;
    }
    
    MPMediaPickerController *picker = [[MPMediaPickerController alloc]init];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = YES;        // 複数選択可
    [self presentViewController:picker animated:YES completion:nil];    //Libraryを開く
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_nameData removeObjectAtIndex:indexPath.row]; // 削除ボタンが押された行のデータを配列から削除します。
        NSArray* items = [_mediaItemCollection2 items];
        NSMutableArray* array = [NSMutableArray arrayWithCapacity:[items count]];
        [array addObjectsFromArray:items];
        [array removeObjectAtIndex:indexPath.row];
        _mediaItemCollection2 = [MPMediaItemCollection collectionWithItems:array];
        [_songList deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //if playing delete
        if (_mediaItemCollection2.count<1) {//1曲の時
            //選択初期化
            avPlayer=nil;
            _timelabel.text=[NSString stringWithFormat:@"00:00"];
            _maxtimelabel.text=[NSString stringWithFormat:@"-00:00"];
            _titlelabel.text=[NSString stringWithFormat:@"曲が選択されていません"];
            [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
            
            
        }else{//2曲以上の時
            if (indexPath.row==_songCount) {//選択中の曲を削除
                
                if (_songCount==_mediaItemCollection2.count) {//最後なら1つ前の曲へ
                    _songCount--;
                    [self nextandback];
                }else{//最後以外は次の曲へ=同じカウントでセットしなおし
                    [self nextandback];
                    [_songList selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
                [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
                
            }else if(indexPath.row<_songCount){//選択中より上の曲を削除
                _songCount--;
                
            }
            NSIndexPath* indexPath2 = [NSIndexPath indexPathForRow:_songCount inSection:0];
            [_songList selectRowAtIndexPath:indexPath2 animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        
        [self savesongList];
        [self saveCount];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//editで曲順入れ替え
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    if(fromIndexPath.section == toIndexPath.section) { // 移動元と移動先は同じセクションです。
        if(_nameData && toIndexPath.row < [_nameData count]) {
            id nameitem = [_nameData objectAtIndex:fromIndexPath.row]; // 移動対象を保持します。
            [_nameData removeObjectAtIndex:fromIndexPath.row]; // 配列から一度消します。
            [_nameData insertObject:nameitem atIndex:toIndexPath.row]; // 保持しておいた対象を挿入します。
            
            NSMutableArray *mutableitems = [[_mediaItemCollection2 items]mutableCopy];
            id nameitem1 = [mutableitems objectAtIndex:fromIndexPath.row]; // 移動対象を保持します。
            [mutableitems removeObjectAtIndex:fromIndexPath.row]; // 配列から一度消します。
            [mutableitems insertObject:nameitem1 atIndex:toIndexPath.row]; // 保持しておいた対象を挿入します。
            _mediaItemCollection2=[[MPMediaItemCollection alloc]initWithItems:mutableitems];
            
            NSLog(@"count:%ld from:%ld to:%ld",_songCount,(long)fromIndexPath.row,(long)toIndexPath.row);
            if (_songCount==fromIndexPath.row) {
                _songCount=toIndexPath.row;
            }else if(_songCount>fromIndexPath.row){//再生中より上を触った時
                if (_songCount>toIndexPath.row) {
                    //上からとって上に入れる。+-0
                    NSLog(@"上−>上");
                }
                if (_songCount<=toIndexPath.row) {
                    //上からとって下に入れる。-1
                    _songCount=_songCount-1;
                    NSLog(@"上−>下");
                }
            }else if(_songCount<fromIndexPath.row){//再生中より下を触った時
                if (_songCount>=toIndexPath.row) {
                    //下からとって上に入れる。+1
                    _songCount=_songCount+1;
                    NSLog(@"下−>上");
                }
                if (_songCount<toIndexPath.row) {
                    //下からとって下に入れる。+-0
                    NSLog(@"下−>下");
                }
            }
            [self savesongList];
            [self saveCount];
        }
    }
}

- (void)avPlayDidFinish:(NSNotification*)notification
{
    if(_mediaItemCollection2.count != 0){               //１曲以上選ばれているか
        NSLog(@"次の曲通知");
        if (_songCount==_mediaItemCollection2.count-1) {//最後なら1曲目へ
            _songCount=0;
            _seekPlaying=NO;
            [self saveCount];
            
            [self nextandback];
            if ((_repeatCount==2)||(_repeatCount==1)) {//リピートなら戻って再生続ける
                [avPlayer play];
            }else{//リピートじゃないなら再生アイコンに
                [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
            }
        }
        else{           //最後じゃないなら次の曲へ
            if (_repeatCount==1) {//同じ曲リピートだからsongCountを+しない
                
            }else{//次の曲
                _songCount++;
            }
            [self saveCount];
            [self nextandbackplay];
        }
        
    }
}

- (void)didChangeAudioSessionRoute:(NSNotification *)notification
{
    // ヘッドホンが刺さっていたか取得
    BOOL (^isJointHeadphone)(NSArray *) = ^(NSArray *outputs){
        for (_desc in outputs) {
            if ([_desc.portType isEqual:AVAudioSessionPortHeadphones]) {
                return YES;
            }
        }
        return NO;
    };
    
    // 直前の状態を取得
    AVAudioSessionRouteDescription *prevDesc = notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
    
    if (isJointHeadphone([[[AVAudioSession sharedInstance] currentRoute] outputs])) {
        if (!isJointHeadphone(prevDesc.outputs)) {
            NSLog(@"ヘッドフォンが刺さった");
            [self ipodLabelDefault];
        }
    } else {
        if(isJointHeadphone(prevDesc.outputs)) {
            NSLog(@"ヘッドフォンが抜かれた");
            [self ipodLabelRed];
            
            [avPlayer pause];
            [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
            
            [_mypod auClose];
            [_mypod2 auClose];
            _feedvol.minimumTrackTintColor=[UIColor lightGrayColor];
            _fbVolLabel.textColor=[UIColor lightGrayColor];
            _delaytime.minimumTrackTintColor=[UIColor lightGrayColor];
            _delaytimeLabel.textColor=[UIColor lightGrayColor];
            
            [_micimage setImage : [ UIImage imageNamed : @"micoffbutton.png" ] forState : UIControlStateNormal];
            _miccount=NO;
        }
    }
}

-(void)telephoneObserver:(NSNotification *)notification{
    NSDictionary* userInfo = notification.userInfo;
    
    AVAudioSessionInterruptionType audioSessionInterruptionType = [userInfo[@"AVAudioSessionInterruptionTypeKey"] longValue];
    switch (audioSessionInterruptionType) {
        case AVAudioSessionInterruptionTypeBegan:
            NSLog(@"割り込みの開始！");
            [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
            [avPlayer pause];
            [_mypod auClose];
            [_mypod2 auClose];
            _feedvol.minimumTrackTintColor=[UIColor lightGrayColor];
            _fbVolLabel.textColor=[UIColor lightGrayColor];
            _delaytime.minimumTrackTintColor=[UIColor lightGrayColor];
            _delaytimeLabel.textColor=[UIColor lightGrayColor];
            [_micimage setImage : [ UIImage imageNamed : @"micoffbutton.png" ] forState : UIControlStateNormal];
            _miccount=NO;
            
            break;
        case AVAudioSessionInterruptionTypeEnded:
            NSLog(@"割り込みの終了！");
            break;
            
        default:
            break;
    }
}

- (IBAction)pick:(id)sender {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc]init];
    
    picker.delegate = self;
    
    picker.allowsPickingMultipleItems = YES;        // 複数選択可
    // picker.prompt = @"Add songs to play";//上に文字出せる
    [self presentViewController:picker animated:YES completion:nil];    //Libraryを開く
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];     //キャンセルで曲選択を終わる
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection       //曲選択後
{
    if (_addFlag) {
        NSMutableArray *mutableitems = [[_mediaItemCollection2 items]mutableCopy];
        [mutableitems addObjectsFromArray:[mediaItemCollection items]];
        _mediaItemCollection2=[[MPMediaItemCollection alloc]initWithItems:mutableitems];
        _nameData=[[NSMutableArray alloc]init];
        for (int i = 0;i < _mediaItemCollection2.count; i++) {
            MPMediaItem *nameitem1=[_mediaItemCollection2.items objectAtIndex:i];
            _name1=[nameitem1 valueForProperty:MPMediaItemPropertyTitle];
            [_nameData addObject:_name1];
        }
        
        if (avPlayer==nil) {
            [self songtext];
            MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:0];
            _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
            _playerItem = [[AVPlayerItem alloc] initWithURL:_url];    //変換
            avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
            
            avPlayer.volume=_ipodVol;
        }
        
    }else{
        [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
        _songCount=0;
        [self saveCount];
        //曲名取得
        _mediaItemCollection2=mediaItemCollection;
        
        [self songtext];
        MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:0];
        _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
        _playerItem = [[AVPlayerItem alloc] initWithURL:_url];    //変換
        avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
        
        avPlayer.volume=_ipodVol;
        
        _nameData=[[NSMutableArray alloc]init];
        for (int i = 0;i < _mediaItemCollection2.count; i++) {
            MPMediaItem *nameitem1=[_mediaItemCollection2.items objectAtIndex:i];
            
            _name1=[nameitem1 valueForProperty:MPMediaItemPropertyTitle];
            _name2=[[nameitem1 valueForProperty:MPMediaItemPropertyAlbumTrackNumber]stringValue];
            
            //NSString* str1 = [NSString stringWithFormat: @"%4@", _name2];
            //NSLog(@"%@",str1);
            
            [_nameData addObject:_name1];
            
            //NSLog(@"%@",[_nameData objectAtIndex:i]);
            NSLog(@"%d曲目　%@",i,[_nameData objectAtIndex:i]);
        }
    }
    [self savesongList];
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
    [_songList reloadData];
    [self AutoScroll];
    [self startTimer];
    _addFlag=NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _nameData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    // 再利用できるセルがあれば再利用する
    UITableViewCell *cell = [_songList dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        // 再利用できない場合は新規で作成
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = self.nameData[indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld",(long)indexPath.row);
    _songCount=(int)indexPath.row;
    [self saveCount];
    [self nextandbackplay];
    _seekPlaying=YES;
    //[ttableView reloadData];
}

- (IBAction)backSong:(id)sender {
    [self backsong];
}

-(void)backsong{
    if(_nameData != 0){                     //１曲以上選ばれているか
        if (CMTimeGetSeconds(avPlayer.currentTime)<2.9) {//2.9秒以前なら前の曲
            
            if (_songCount==0) {                             //最初なら最後の曲へ
                _songCount=_nameData.count-1;
                [self saveCount];
            }
            else {
                _songCount--;    //前の曲へ
                [self saveCount];
            }
            
            if ([avPlayer rate]==0) {  //曲が停止中なら停止
                [self nextandback];
            }else{  //曲が再生中なら再生
                [self nextandbackplay];
            }
        }
        else{[avPlayer seekToTime:CMTimeMake(0, 600)];}//2.9秒以降なら0秒
    }
}

- (IBAction)nextSong:(id)sender {
    [self nextsong];
}

-(void)nextsong{
    //NSLog(@"%lu",(unsigned long)_mediaItemCollection2.count);
    if(_nameData.count != 0){               //１曲以上選ばれているか
        if (_songCount==_nameData.count-1) {//最後なら1曲目へ
            _songCount=0;
            [self saveCount];
        }
        else{           //次の曲へ
            if (_repeatCount!=1) {
                _songCount++;
            }
            
            [self saveCount];
        }
        if ([avPlayer rate]==0) {  //曲が停止中なら停止
            [self nextandback];
        }else{  //曲が再生中なら停止
            [self nextandbackplay];
        }
    }
}

-(void)nextandback{
    MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:_songCount];
    [self songtext];
    [self AutoScroll];
    _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    _playerItem = [[AVPlayerItem alloc] initWithURL:_url];
    avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
    
    avPlayer.volume=_ipodVol;
    
}

-(void)nextandbackplay{
    MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:_songCount];
    [self songtext];
    [self AutoScroll];
    _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    _playerItem = [[AVPlayerItem alloc] initWithURL:_url];
    avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
    
    avPlayer.volume=_ipodVol;
    
    [avPlayer play];
    [_playImage setImage : [ UIImage imageNamed : @"pauseClear.png" ] forState : UIControlStateNormal];
}


- (IBAction)pushPlay:(id)sender {
    [self pushPlay];
}

-(void)pushPlay{
    if (_nameData.count != 0){
        if ([avPlayer rate]!=0) {  //曲が再生中なら停止
            [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
            [avPlayer pause];
            _seekPlaying=NO;
        }else{  //曲が停止中なら再生
            [_playImage setImage : [ UIImage imageNamed : @"pauseClear.png" ] forState : UIControlStateNormal];
            [avPlayer play];
            _seekPlaying=YES;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)ipodSliderChanged:(UISlider*)sender {   //曲のボリューム変更スライダー
    _ipodVol = sender.value;
    avPlayer.volume=_ipodVol;
    
    if (_headphoneConnect) {
        _ipodVoltext = [NSString stringWithFormat:@"%.0f", _ipodVol*IPOD_VOL];
        
        NSUserDefaults *ud1=[NSUserDefaults standardUserDefaults];
        [ud1 setFloat:_ipodVol forKey:@"ipodvol"];
    }else{
        _ipodVoltext = [NSString stringWithFormat:@"%.0f", _ipodVol*IPOD_VOL/10];
        
        NSUserDefaults *ud6=[NSUserDefaults standardUserDefaults];
        [ud6 setFloat:_ipodVol forKey:@"speakervol"];
    }
    _ipodVolLabel.text=_ipodVoltext;
}

- (IBAction)feedSliderChanged:(UISlider*)sender {   //フィードバック音のボリューム変更スライダー
    float rv = 1/sender.value;
    float log=-10*log2(rv);
    float db =pow(10, log/20);
    NSLog(@"%f",db);
    _mypod.feedVol=db;
    _mypod2.feedVol=db;
    if (_miccount) {
        [_mypod mixUnitvol];
        [_mypod2 mixUnitvol];
    }
    NSString *fbVoltext = [NSString stringWithFormat:@"%.0f", sender.value*100];
    _fbVolLabel.text=fbVoltext;
    
    NSUserDefaults *ud2=[NSUserDefaults standardUserDefaults];
    [ud2 setFloat:_mypod.feedVol forKey:@"feedvol"];
    [ud2 setFloat:_mypod2.feedVol forKey:@"feedvol"];
}

- (IBAction)delaySliderChanged:(UISlider*)sender {//フィードバック音の遅延変更スライダー
    NSLog(@"delay");
    _mypod.delayTime=sender.value;
    _mypod2.delayTime=sender.value;
    if (_miccount) {
        [_mypod delayUnittime];
        [_mypod2 delayUnittime];
    }
    NSString *delaytimetext = [NSString stringWithFormat:@"%.1f", _mypod.delayTime*2];
    _delaytimeLabel.text=delaytimetext;
    
    NSUserDefaults *ud7=[NSUserDefaults standardUserDefaults];
    [ud7 setFloat:_mypod.delayTime forKey:@"delayTime"];
    [ud7 setFloat:_mypod2.delayTime forKey:@"delayTime"];
}

-(void)saveCount{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        NSUserDefaults *ud5=[NSUserDefaults standardUserDefaults];
        [ud5 setFloat:_songCount forKey:@"songCount"];
        NSUserDefaults *ud6=[NSUserDefaults standardUserDefaults];
        [ud6 setFloat:_repeatCount forKey:@"repeatCount"];
    }
}

-(void)savesongList{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        _mediaitemData = [NSKeyedArchiver archivedDataWithRootObject:_mediaItemCollection2];
        NSUserDefaults *ud4=[NSUserDefaults standardUserDefaults];
        [ud4 setObject:_mediaitemData forKey:@"_mediaitemData"];
    }
}

-(void)songtext{
    MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:_songCount];
    _titlelabel.text =[item valueForProperty:MPMediaItemPropertyTitle];
    _albumlabel.text =[item valueForProperty:MPMediaItemPropertyAlbumTitle];
    
    NSString *playbackstr=[item valueForProperty:MPMediaItemPropertyPlaybackDuration];
    _playback=playbackstr.intValue;
    _autoseek.maximumValue=_playback;
    
    _songinfo=@{MPMediaItemPropertyTitle:[item valueForProperty:MPMediaItemPropertyTitle],
                MPMediaItemPropertyPlaybackDuration:[item valueForProperty:MPMediaItemPropertyPlaybackDuration]
                };
    //[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:_songinfo];
}

-(void)startTimer{
    _timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timertext) userInfo:nil repeats:YES];
}

-(void)timertext{
    _getSecond=CMTimeGetSeconds(avPlayer.currentTime);
    _second=fmodf(_getSecond,60);
    _minute=_getSecond/60;
    _timestr=[NSString stringWithFormat:@"%02d:%02d",_minute,_second];
    _timelabel.text=_timestr;
    
    _maxback=_playback-CMTimeGetSeconds(avPlayer.currentTime);
    _maxsecond=_maxback%60;
    _maxminute=_maxback/60;
    _maxtimelabelstr=[NSString stringWithFormat:@"-%02d:%02d",_maxminute,_maxsecond];
    _maxtimelabel.text=_maxtimelabelstr;
    [_autoseek setValue:CMTimeGetSeconds(avPlayer.currentTime) animated:YES];
}

- (IBAction)seekslider:(UISlider *)sender {
    _newValue=sender.value;
    [_timer invalidate];
    if (fabsf(_newValue-_oldValue)>(_playback/500)) {
        
        _tm= CMTimeMakeWithSeconds((int)sender.value, NSEC_PER_SEC);
        [avPlayer pause];
        [avPlayer seekToTime:_tm];
        
        if (_seekPlaying && _playback-sender.value>1) {
            [NSThread sleepForTimeInterval:0.04];
            [avPlayer play];
        }
        
        NSLog(@"%f",_playback-sender.value);
        
        _senderval=sender.value;
        _second=_senderval%60;
        _minute=sender.value/60;
        _timestr=[NSString stringWithFormat:@"%02d:%02d",_minute,_second];
        _timelabel.text=_timestr;
        _maxback=_playback-sender.value;
        _maxsecond=_maxback%60;
        _maxminute=_maxback/60;
        _maxtimelabelstr=[NSString stringWithFormat:@"-%02d:%02d",_maxminute,_maxsecond];
        _maxtimelabel.text=_maxtimelabelstr;
        
    }
    _oldValue=_newValue;
}

- (IBAction)feedUp:(UISlider *)sender {
    if (_seekPlaying) {
        [avPlayer play];
    }
    [_autoseek setValue:sender.value animated:YES];
    [avPlayer seekToTime:_tm];
    
    [self startTimer];
    NSLog(@"離した%f",CMTimeGetSeconds(avPlayer.currentTime));
}

- (IBAction)feedDown:(UISlider *)sender {//シークバー操作中
    _oldValue=sender.value;
    
    if ([avPlayer rate]==0) {
        _seekPlaying=NO;
        NSLog(@"NO");
    }else{
        _seekPlaying=YES;
        NSLog(@"YES");
    }
}

- (IBAction)repeatBtn:(UIButton *)sender {//0=リピート無し,1=1曲リピート,2=Allリピート
    NSLog(@"repeat押した");
    if (_repeatCount==2) {//1
        _repeatCount=1;
        [_repeatImage setImage : [ UIImage imageNamed : @"repeat11.png" ] forState : UIControlStateNormal];
    }else if (_repeatCount==1){//all
        _repeatCount=0;
        [_repeatImage setImage : [ UIImage imageNamed : @"repeat0.png" ] forState : UIControlStateNormal];
    }else{//non
        _repeatCount=2;
        [_repeatImage setImage : [ UIImage imageNamed : @"repeata.png" ] forState : UIControlStateNormal];
    }
    [self saveCount];
}

-(void)AutoScroll{
    if (_songCount<_nameData.count) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:_songCount inSection:0];
        [_songList selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

- (IBAction)miconoff:(UIButton *)sender {
    [self miconoff];
}

-(void)miconoff{
    if (!_miccount) {
        //[_mypod audioSession];
        [_mypod feed];
        [_mypod bufferSet];
        [_mypod mixUnitvol];
        [_mypod delayUnittime];
        //[_mypod2 audioSession];
        [_mypod2 feed];
        [_mypod2 bufferSet];
        [_mypod2 mixUnitvol];
        [_mypod2 delayUnittime];
        _feedvol.minimumTrackTintColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        _fbVolLabel.textColor=[UIColor blackColor];
        _delaytime.minimumTrackTintColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        _delaytimeLabel.textColor=[UIColor blackColor];
        
        [_micimage setImage : [ UIImage imageNamed : @"miconbutton.png" ] forState : UIControlStateNormal];
        _miccount=YES;
    }else{
        [_mypod auClose];
        [_mypod2 auClose];
        _feedvol.minimumTrackTintColor=[UIColor lightGrayColor];
        _fbVolLabel.textColor=[UIColor lightGrayColor];
        _delaytime.minimumTrackTintColor=[UIColor lightGrayColor];
        _delaytimeLabel.textColor=[UIColor lightGrayColor];
        
        [_micimage setImage : [ UIImage imageNamed : @"micoffbutton.png" ] forState : UIControlStateNormal];
        _miccount=NO;
    }
}

-(void)ipodLabelDefault{//イヤホン挿さってる時
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    _ipodVol = [ud floatForKey:@"ipodvol"];
    
    _musicIcon.textColor=_ipodVolLabel.textColor=[UIColor blackColor];
    _ipodvol.minimumTrackTintColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    _ipodvol.maximumValue=0.1;
    _ipodVoltext = [NSString stringWithFormat:@"%.0f", _ipodVol*IPOD_VOL];
    
    _ipodvol.value=_ipodVol;
    _ipodVolLabel.text=_ipodVoltext;
    avPlayer.volume=_ipodVol;
    
    _headphoneConnect=YES;
}

-(void)ipodLabelRed{//イヤホン刺さってない時
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    _ipodVol = [ud floatForKey:@"speakervol"];
    
    _musicIcon.textColor=_ipodVolLabel.textColor=[UIColor redColor];
    _ipodvol.minimumTrackTintColor=[UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0];
    _ipodvol.maximumValue=1;
    _ipodVoltext = [NSString stringWithFormat:@"%.0f", _ipodVol*IPOD_VOL/10];
    
    _ipodvol.value=_ipodVol;
    _ipodVolLabel.text=_ipodVoltext;
    avPlayer.volume=_ipodVol;
    
    _headphoneConnect=NO;
}
@end
