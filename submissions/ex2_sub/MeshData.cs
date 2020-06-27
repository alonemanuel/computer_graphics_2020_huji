using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using UnityEngine;
using Vector3 = UnityEngine.Vector3;


public class MeshData
{
    public List<Vector3> vertices; // The vertices of the mesh 
    public List<int> triangles; // Indices of vertices that make up the mesh faces
    public Vector3[] normals; // The normals of the mesh, one per vertex

    // Class initializer
    public MeshData()
    {
        vertices = new List<Vector3>();
        triangles = new List<int>();
    }

    // Returns a Unity Mesh of this MeshData that can be rendered
    public Mesh ToUnityMesh()
    {
        Mesh mesh = new Mesh
        {
            vertices = vertices.ToArray(),
            triangles = triangles.ToArray(),
            normals = normals
        };

        return mesh;
    }

    // Calculates surface normals for each vertex, according to face orientation
    public void CalculateNormals()
    {
        // Your implementation
        List<Vector3> surfaceNormals = calculateSurfaceNormals();


        normals = new Vector3[vertices.Count];
        for (int vertexI = 0; vertexI < vertices.Count; vertexI++)
        {
            normals[vertexI] = calculateVertexNormal(vertexI, surfaceNormals);
        }
    }

    private List<Vector3> calculateSurfaceNormals()
    {
        List<Vector3> surfaceNormals = new List<Vector3>();
        for (int i = 0; i < triangles.Count; i += 3)
        {
            Vector3 v0 = vertices[triangles[i]] - vertices[triangles[i + 2]];
            Vector3 v1 = vertices[triangles[i + 1]] - vertices[triangles[i + 2]];
            Vector3 surfaceNormal = Vector3.Cross(v0, v1);
            surfaceNormals.Add(surfaceNormal.normalized);
        }


        return surfaceNormals;
    }

    private Vector3 calculateVertexNormal(int vertexIndex, List<Vector3> surfaceNormals)
    {
        List<int> surfaceIndices = getSurfacesIndicesPerVertex(vertexIndex);
        Vector3 sumOfSurfaceNormals = Vector3.zero;
        foreach (int surfaceI in surfaceIndices)
        {
            sumOfSurfaceNormals += surfaceNormals[surfaceI / 3];
        }

        return sumOfSurfaceNormals.normalized;
    }

    private List<int> getSurfacesIndicesPerVertex(int vertexIndex)
    {
        List<int> surfaceIndices = new List<int>();
        for (int i = 0; i < triangles.Count; i++)
        {
            if (triangles[i] == vertexIndex)
            {
                surfaceIndices.Add(i);
            }
        }

        // todo: check if this can be done in O(1) instead of O(n)
        return surfaceIndices;
    }

    // Edits mesh such that each face has a unique set of 3 vertices
    public void MakeFlatShaded()
    {
        // Your implementation
        List<int> flattenedTriangles = new List<int>(triangles);

        List<Vector3> flattenedVertices = new List<Vector3>();
        for (int vertexI = 0; vertexI < vertices.Count; vertexI++)
        {
            List<int> currSurfaceIndices = getSurfacesIndicesPerVertex(vertexI);
            for (int surfaceI = 0; surfaceI < currSurfaceIndices.Count; surfaceI++)
            {
                Vector3 currVertex = vertices[vertexI];
                flattenedTriangles[currSurfaceIndices[surfaceI]] = flattenedVertices.Count;
//                flattenedVertices.Add(new Vector3(currVertex.x, currVertex.y, currVertex.z));
                flattenedVertices.Add(currVertex);
            }
        }

        triangles = flattenedTriangles;

        vertices = flattenedVertices;
    }
}