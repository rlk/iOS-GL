#import <GLKit/GLKit.h>

#import "Shader.h"

@implementation Shader

- (id)initWithVert:(NSString *)vertPathname frag:(NSString *)fragPathname
{
    // Compile the shaders.
 
    vertShader = [self compile:GL_VERTEX_SHADER   file:vertPathname];
    fragShader = [self compile:GL_FRAGMENT_SHADER file:fragPathname];

    
    program    = [self link:vertShader with:fragShader];
    
    return self;
}

- (void)dealloc
{
    glDeleteShader(vertShader);
    glDeleteShader(fragShader);
    glDeleteProgram(program);
}

//------------------------------------------------------------------------------

- (GLuint)uniform:(NSString *)name
{
    return glGetUniformLocation(program, [name UTF8String]);
}

- (void)use
{
    glUseProgram(program);
}

//------------------------------------------------------------------------------

- (GLuint)compile:(GLenum)type file:(NSString *)file
{
    GLuint shader = 0;
    GLint  status;
    
    // Load the source.
    
    const GLchar *source;
    source = (GLchar *)[[NSString stringWithContentsOfFile:file
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil] UTF8String];
    if (source)
    {
        // Create and compile the shader.
        
        shader = glCreateShader(type);
        glShaderSource (shader, 1, &source, NULL);
        glCompileShader(shader);
        
        // Log any errors and check the compile status.
        
        [self logShader:shader];
        
        glGetShaderiv(shader, GL_COMPILE_STATUS, &status);

        if (status == 0)
        {
            glDeleteShader(shader);
            return 0;
        }
    }
    else NSLog(@"Failed to load vertex shader");

    return shader;
}

- (GLuint)link:(GLuint)vert with:(GLuint)frag
{
    GLuint prog = 0;
    
    if (vert && frag)
    {
        // Initialize the program.
        
        prog = glCreateProgram();
        
        glAttachShader(prog, vert);
        glAttachShader(prog, frag);
        
        // Bind attribute locations before linking.
        
        glBindAttribLocation(prog, GLKVertexAttribPosition, "position");
        glBindAttribLocation(prog, GLKVertexAttribNormal,   "normal");
        
        // Link the program.
        
        glLinkProgram(prog);
        
        // Log any errors and check the link status.
        
        [self logProgram:prog];

        GLint status;
        glGetProgramiv(prog, GL_LINK_STATUS, &status);

        if (status == 0)
        {
            glDeleteProgram(prog);
            return 0;
        }
    }
    return prog;
}

//------------------------------------------------------------------------------

- (void)logShader:(GLuint)shader
{
    GLint len;
    
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &len);
    
    if (len > 0)
    {
        GLchar *log = (GLchar *) calloc(len + 1, 1);
        glGetShaderInfoLog(shader, len, &len, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
}

- (void)logProgram:(GLuint)prog
{
    GLint len;
    
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &len);
    
    if (len > 0)
    {
        GLchar *log = (GLchar *) calloc(len + 1, 1);
        glGetProgramInfoLog(prog, len, &len, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
}

//------------------------------------------------------------------------------

@end
