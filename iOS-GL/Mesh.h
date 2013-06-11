#import <Foundation/Foundation.h>

struct vert
{
    GLfloat v[3];
    GLfloat n[3];
};

struct elem
{
    GLint i[3];
};

@interface Mesh : NSObject
{
    GLuint arrays;
    GLuint vbo;
    GLuint ebo;
    
    struct vert *verts;
    struct elem *elems;
    
    int nverts;
    int nelems;
}

- (id)initWithFile:(NSString *)name;

- (void)draw;

@end
