#import "ViewController.h"

//------------------------------------------------------------------------------

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context)
        NSLog(@"Failed to create ES context");

    GLKView *view = (GLKView *) self.view;

    view.context             = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self initGL];
}

- (void)dealloc
{    
    [self finiGL];
    
    if ([EAGLContext currentContext] == self.context)
        [EAGLContext setCurrentContext:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil))
    {
        self.view = nil;
        
        [self finiGL];
        
        if ([EAGLContext currentContext] == self.context)
            [EAGLContext setCurrentContext:nil];

        self.context = nil;
    }
}

//------------------------------------------------------------------------------

- (void)initGL
{
    [EAGLContext setCurrentContext:self.context];

    NSString *vertPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    NSString *fragPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    NSString *meshPathname = [[NSBundle mainBundle] pathForResource:@"bunny"  ofType:@"dat"];
    
    // Initialize the shader.
    
    shader = [[Shader alloc] initWithVert:vertPathname
                                    frag:fragPathname];

    uniformMVP = [shader uniform:@"modelViewProjectionMatrix"];
    uniformN   = [shader uniform:@"normalMatrix"];
    
    // Initialize the model.

    mesh = [[Mesh alloc] initWithFile:meshPathname];
    
    // Set other global GL state.
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
}

- (void)finiGL
{
    [EAGLContext setCurrentContext:self.context];
}

//------------------------------------------------------------------------------

- (void)update
{
    GLKMatrix4 P;
    GLKMatrix4 V;
    GLKMatrix4 M;
    GLKMatrix4 MV;

    // Perspective matrix.
    
    float fov    = GLKMathDegreesToRadians(45.0f);
    float aspect = fabsf(self.view.bounds.size.width
                       / self.view.bounds.size.height);
    
    P   = GLKMatrix4MakePerspective(fov, aspect, 0.1f, 100.0f);
    
    // View matrix.
    
    V   = GLKMatrix4MakeTranslation(0.0f, 0.0f, -2.0f);
    
    // Model matrix.
    
    M   = GLKMatrix4MakeRotation(rotX, 1.0f,  0.0f, 0.0f);
    M   = GLKMatrix4Rotate   (M, rotY, 0.0f,  1.0f, 0.0f);
    M   = GLKMatrix4Translate(M,       0.0f, -0.5f, 0.0f);

    // MVP.
    
    MV  = GLKMatrix4Multiply(V, M);
    N   = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(MV), NULL);
    MVP = GLKMatrix4Multiply(P, MV);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [shader use];
    
    glUniformMatrix4fv(uniformMVP, 1, 0, MVP.m);
    glUniformMatrix3fv(uniformN,   1, 0, N.m);
    
    [mesh draw];
}

//------------------------------------------------------------------------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    start = [touch locationInView:self.view];
    rotX0 = rotX;
    rotY0 = rotY;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];

    int dx = point.y - start.y;
    int dy = point.x - start.x;
    
    rotX = rotX0 + dx / 200.0;
    rotY = rotY0 + dy / 200.0;
}

//------------------------------------------------------------------------------

@end
