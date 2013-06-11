#import <GLKit/GLKit.h>

#import "Mesh.h"

@implementation Mesh

- (id)initWithFile:(NSString *)name
{
    FILE *fp;

    if ((fp = fopen([name UTF8String], "r")))
    {
        // Load the mesh data from the named file.
        
        fscanf(fp, "%d %d\n", &nverts, &nelems);
        
        verts = (struct vert *) malloc(nverts * sizeof (struct vert));
        elems = (struct elem *) malloc(nelems * sizeof (struct elem));

        for (int i = 0; i < nverts; i++)
            fscanf(fp, "%f %f %f %f %f %f\n",
                   &verts[i].v[0], &verts[i].v[1], &verts[i].v[2],
                   &verts[i].n[0], &verts[i].n[1], &verts[i].n[2]);

        for (int i = 0; i < nelems; i++)
            fscanf(fp, "%d %d %d\n",
                   &elems[i].i[0], &elems[i].i[1], &elems[i].i[2]);

        fclose(fp);
    
        // Copy the mesh data to a pair of buffer objects.
        
        glGenVertexArraysOES(1, &arrays);
        glBindVertexArrayOES(arrays);
        {
            glGenBuffers(1,              &vbo);
            glBindBuffer(GL_ARRAY_BUFFER, vbo);
            glBufferData(GL_ARRAY_BUFFER, nverts * sizeof (struct vert),
                                           verts, GL_STATIC_DRAW);

            glGenBuffers(1,                      &ebo);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, nelems * sizeof (struct elem),
                                                   elems, GL_STATIC_DRAW);
            
            glEnableVertexAttribArray(GLKVertexAttribPosition);
            glVertexAttribPointer    (GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE,
                                      sizeof (struct vert), (GLvoid *)  0);
            glEnableVertexAttribArray(GLKVertexAttribNormal);
            glVertexAttribPointer    (GLKVertexAttribNormal,   3, GL_FLOAT, GL_FALSE,
                                      sizeof (struct vert), (GLvoid *) 12);
        }
        glBindVertexArrayOES(0);
    }
    return self;
}

- (void)dealloc
{
    glDeleteBuffers        (1, &ebo);
    glDeleteBuffers        (1, &vbo);
    glDeleteVertexArraysOES(1, &arrays);
}

- (void)draw
{
    glBindVertexArrayOES(arrays);
    {
        glDrawElements(GL_TRIANGLES, nelems * 3, GL_UNSIGNED_INT, 0);
    }
    glBindVertexArrayOES(0);
}

@end
