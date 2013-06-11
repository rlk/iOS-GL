#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#import "Shader.h"
#import "Mesh.h"

@interface ViewController : GLKViewController
{
    Shader *shader;
    Mesh   *mesh;
    
    float rotX;
    float rotY;

    float rotX0;
    float rotY0;

    GLKMatrix4 MVP;
    GLKMatrix3 N;
    
    GLuint uniformMVP;
    GLuint uniformN;
    
    CGPoint start;
}

@property (strong, nonatomic) EAGLContext *context;

- (void)initGL;
- (void)finiGL;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

@end
