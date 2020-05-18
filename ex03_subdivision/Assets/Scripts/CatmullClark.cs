﻿using System;
using System.Collections.Generic;
using UnityEngine;


public class CCMeshData
{
    public List<Vector3> points; // Original mesh points
    public List<Vector4> faces; // Original mesh quad faces
    public List<Vector4> edges; // Original mesh edges
    public List<Vector3> facePoints; // Face points, as described in the Catmull-Clark algorithm
    public List<Vector3> edgePoints; // Edge points, as described in the Catmull-Clark algorithm
    public List<Vector3> newPoints; // New locations of the original mesh points, according to Catmull-Clark
}


public static class CatmullClark
{
    // Returns a QuadMeshData representing the input mesh after one iteration of Catmull-Clark subdivision.
    public static QuadMeshData Subdivide(QuadMeshData quadMeshData)
    {
        // Create and initialize a CCMeshData corresponding to the given QuadMeshData
        CCMeshData meshData = new CCMeshData();
        meshData.points = quadMeshData.vertices;
        meshData.faces = quadMeshData.quads;
        meshData.edges = GetEdges(meshData);
        meshData.facePoints = GetFacePoints(meshData);
        meshData.edgePoints = GetEdgePoints(meshData);
        meshData.newPoints = GetNewPoints(meshData);

        // Combine facePoints, edgePoints and newPoints into a subdivided QuadMeshData

        // Your implementation here...

        return new QuadMeshData();
    }

    // Returns a list of all edges in the mesh defined by given points and faces.
    // Each edge is represented by Vector4(p1, p2, f1, f2)
    // p1, p2 are the edge vertices
    // f1, f2 are faces incident to the edge. If the edge belongs to one face only, f2 is -1
    public static List<Vector4> GetEdges(CCMeshData mesh)
    {
        Vec2Comparer c = new Vec2Comparer();
        Dictionary<Vector2, List<int>> edgesDict = new Dictionary<Vector2, List<int>>(c);


        List<Vector4> edges = new List<Vector4>();
        // todo: we're assuming the points in the faces are ordered

        for (int i = 0; i < mesh.faces.Count; i++)
        {
            Debug.Log($"Processing face {i}...");
            Vector4 currFace = mesh.faces[i];
            for (int j = 0; j < 4; j++)
            {
                int firstPointIndex = (int) currFace[j];
                int secondPointIndex = (int) currFace[(j + 1) % 4]; // so the points are cyclic

                Vector2 newEdge = new Vector2(firstPointIndex, secondPointIndex);
                if (!edgesDict.ContainsKey(newEdge))
                {
                    edgesDict.Add(newEdge, new List<int>());
                }

                edgesDict[newEdge].Add(i);
            }
        }

        foreach (KeyValuePair<Vector2, List<int>> edge in edgesDict)
        {
            Debug.Log($"Processing edge ({edge.Key.x}, {edge.Key.y})...");
            Vector4 newEdge = new Vector4(edge.Key.x, edge.Key.y, edge.Value[0], edge.Value[1]);
            edges.Add(newEdge);
        }

        return edges;
    }

    public class Vec2Comparer : EqualityComparer<Vector2>
    {
        private static readonly float EPSILON = 1e-5f;

        public override bool Equals(Vector2 firstPoint, Vector2 secondPoint)
        {
            bool areSame = (firstPoint.x == secondPoint.x) && (firstPoint.y == secondPoint.y);
            bool areFlipped = (firstPoint.x == secondPoint.y) && (firstPoint.y == secondPoint.x);
            if (areSame || areFlipped)
            {
                return true;
            }

            return false;
        }

        public override int GetHashCode(Vector2 obj)
        {
            return 0;
        }
    }

    // Returns a list of "face points" for the given CCMeshData, as described in the Catmull-Clark algorithm 
    public static List<Vector3> GetFacePoints(CCMeshData mesh)
    {
        return null;
    }

    // Returns a list of "edge points" for the given CCMeshData, as described in the Catmull-Clark algorithm 
    public static List<Vector3> GetEdgePoints(CCMeshData mesh)
    {
        return null;
    }

    // Returns a list of new locations of the original points for the given CCMeshData, as described in the CC algorithm 
    public static List<Vector3> GetNewPoints(CCMeshData mesh)
    {
        return null;
    }
}