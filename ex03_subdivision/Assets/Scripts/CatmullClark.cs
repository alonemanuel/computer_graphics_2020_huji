using System;
using System.Collections.Generic;
using System.Linq;
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
        List<Vector3> vertices = meshData.newPoints.Concat(meshData.facePoints).Concat(meshData.edgePoints).ToList();
        List<Vector4> quads = new List<Vector4>();

        // todo: finish this
        
//        for (int edgePointIndex=0;edgePointIndex<meshData.edgePoints;)

        return new QuadMeshData(vertices, quads);
    }

    private static Dictionary<int, List<Vector3>> getEdgesMidpointsPerPoint(CCMeshData meshData)
    {
        Dictionary<int, List<Vector3>> edgeIndicesPerPoint = new Dictionary<int, List<Vector3>>();

        // init edgeIndicesPerPoint dict
        for (int pointIndex = 0; pointIndex < meshData.points.Count; pointIndex++)
        {
            edgeIndicesPerPoint[pointIndex] = new List<Vector3>();
        }

        // add edges indices to points
        for (int edgeIndex = 0; edgeIndex < meshData.edges.Count; edgeIndex++)
        {
            Vector4 edge = meshData.edges[edgeIndex];


            int point1Index = (int) edge[0];
            int point2Index = (int) edge[1];

            Vector3 point1 = meshData.points[point1Index];
            Vector3 point2 = meshData.points[point2Index];

            Vector3 edgeMidpoint = (point1 + point2) / 2;

            edgeIndicesPerPoint[point1Index].Add(edgeMidpoint);
            edgeIndicesPerPoint[point2Index].Add(edgeMidpoint);
        }

        return edgeIndicesPerPoint;
    }

    private static Dictionary<int, List<int>> getFacesIndicesPerPoint(CCMeshData meshData)
    {
        Dictionary<int, List<int>> faceIndicesPerPoint = new Dictionary<int, List<int>>();

        // init edgeIndicesPerPoint dict
        for (int pointIndex = 0; pointIndex < meshData.points.Count; pointIndex++)
        {
            faceIndicesPerPoint[pointIndex] = new List<int>();
        }

        // add edges indices to points
        for (int faceIndex = 0; faceIndex < meshData.faces.Count; faceIndex++)
        {
            Vector4 face = meshData.faces[faceIndex];
            for (int currPointIndexInFace = 0; currPointIndexInFace < 4; currPointIndexInFace++)
            {
                int currPointIndexInPoints = (int) face[currPointIndexInFace];
                faceIndicesPerPoint[currPointIndexInPoints].Add(faceIndex);
            }
        }

        return faceIndicesPerPoint;
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
        List<Vector3> facePoints = new List<Vector3>();

        for (int faceIndex = 0; faceIndex < mesh.faces.Count; faceIndex++)
        {
            Vector3 sumVector = Vector3.zero;
            for (int pointInFaceIndex = 0; pointInFaceIndex < 4; pointInFaceIndex++)
            {
                int pointInPointsIndex = (int) mesh.faces[faceIndex][pointInFaceIndex];
                Vector3 currPoint = mesh.points[pointInPointsIndex];
                sumVector += currPoint;
            }

            Vector3 facePoint = sumVector / 4;
            facePoints.Add(facePoint);
        }

        return facePoints;
    }

    // Returns a list of "edge points" for the given CCMeshData, as described in the Catmull-Clark algorithm 
    public static List<Vector3> GetEdgePoints(CCMeshData mesh)
    {
        List<Vector3> edgePoints = new List<Vector3>();

        for (int edgeIndex = 0; edgeIndex < mesh.edges.Count; edgeIndex++)
        {
            Vector4 edge = mesh.edges[edgeIndex];
            Vector3 point1 = mesh.points[(int) edge[0]];
            Vector3 point2 = mesh.points[(int) edge[1]];
            Vector3 facePoint1 = mesh.facePoints[(int) edge[2]];
            Vector3 facePoint2 = mesh.facePoints[(int) edge[3]];

            Vector3 edgePoint = (point1 + point2 + facePoint1 + facePoint2) / 4;
            edgePoints.Add(edgePoint);
        }

        return edgePoints;
    }

    // Returns a list of new locations of the original points for the given CCMeshData, as described in the CC algorithm 
    public static List<Vector3> GetNewPoints(CCMeshData mesh)
    {
        List<Vector3> newPoints = new List<Vector3>();
        Dictionary<int, List<Vector3>> edgeMidpointPerPoint = getEdgesMidpointsPerPoint(mesh);
        Dictionary<int, List<int>> facesIndicesPerPoint = getFacesIndicesPerPoint(mesh);


        for (int origPointIndex = 0; origPointIndex < mesh.points.Count; origPointIndex++)
        {
            Vector3 p = mesh.points[origPointIndex]; // p = original point
            List<Vector3> edgeMidpointsOfPoint = edgeMidpointPerPoint[origPointIndex];
            List<int> facesOfPoint = facesIndicesPerPoint[origPointIndex];

            int n = edgeMidpointsOfPoint.Count; // number of edges/faces neighboring p 


            Vector3 f = Vector3.zero; // average of facepoints 
            for (int faceOfPointIndex = 0; faceOfPointIndex < n; faceOfPointIndex++)
            {
                int currFaceOfPointIndex = facesOfPoint[faceOfPointIndex];
                Vector3 facePoint = mesh.facePoints[currFaceOfPointIndex];
                f += facePoint;
            }

            f /= n;


            Vector3 r = Vector3.zero; // average of midpoints
            for (int midpointIndex = 0; midpointIndex < n; midpointIndex++)
            {
                Vector3 midpoint = edgeMidpointsOfPoint[midpointIndex];
                r += midpoint;
            }

            r /= n;


            Vector3 newPoint = (f + 2 * r + (n - 3) * p) / n;
            newPoints.Add(newPoint);
        }


        return newPoints;
    }
}