﻿using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterAnimator : MonoBehaviour
{
    public TextAsset BVHFile; // The BVH file that defines the animation and skeleton
    public bool animate; // Indicates whether or not the animation should be running

    private BVHData data; // BVH data of the BVHFile will be loaded here
    private int currFrame = 0; // Current frame of the animation

    // Start is called before the first frame update
    void Start()
    {
        BVHParser parser = new BVHParser();
        data = parser.Parse(BVHFile);
        CreateJoint(data.rootJoint, Vector3.zero);

        TestRotateTowardsVector();
    }

    private void TestRotateTowardsVector()
    {
        Debug.Log("Now testing");
        List<Vector3> testVectors = new List<Vector3>();
        testVectors.Add(new Vector3(1, 1, 1));
        testVectors.Add(new Vector3(1, 2, 3));
        testVectors.Add(new Vector3(4, 2, 0));
        testVectors.Add(new Vector3(6, 9, 2));

        foreach (Vector3 testV in testVectors)
        {
            Vector3 testVNorm = testV.normalized;
            Debug.Log("NormtestV");
            Debug.Log(testVNorm);
            Matrix4x4 r = RotateTowardsVector(testV);
            Debug.Log("r");
            Debug.Log(r);
            Vector3 resV = r.MultiplyVector(Vector3.up);
            Debug.Log("resV");
            Debug.Log(resV);
            Debug.Log(resV == testVNorm);
            Debug.Log("\n\n");
        }
    }

    // Returns a Matrix4x4 representing a rotation aligning the up direction of an object with the given v
    Matrix4x4 RotateTowardsVector(Vector3 v)
    {
        // Your code here
        Vector3 normV = v.normalized;
        Debug.Log("normV is:");
        Debug.Log(normV);
        float thetaX = 90 - Mathf.Atan2(normV.y, normV.z) * Mathf.Rad2Deg;
        Matrix4x4 rX = MatrixUtils.RotateX(-thetaX);
        Vector3 rxV = rX * normV;
        Debug.Log("The z coordinate should be 0:");
        Debug.Log(rxV);
        float thetaZ = 90 - Mathf.Atan2(rxV.y, rxV.x) * Mathf.Rad2Deg;
        Matrix4x4 rZ = MatrixUtils.RotateZ(thetaZ);
        Vector3 rzrxV = rZ * rxV;
        Debug.Log("This vector should be (0,1,0):");
        Debug.Log(rzrxV);
        Matrix4x4 rXinv = rX.inverse;
        Matrix4x4 rZinv = rZ.inverse;
        Matrix4x4 rXIrZI = rXinv * rZinv;
        return rXIrZI;
    }

    // Creates a Cylinder GameObject between two given points in 3D space
    GameObject CreateCylinderBetweenPoints(Vector3 p1, Vector3 p2, float diameter)
    {
        // Your code here
        return null;
    }

    // Creates a GameObject representing a given BVHJoint and recursively creates GameObjects for it's child joints
    GameObject CreateJoint(BVHJoint joint, Vector3 parentPosition)
    {
        // Your code here
        joint.gameObject = new GameObject(joint.name);
        GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        sphere.transform.parent = joint.gameObject.transform;
        Vector3 scalingVec = (joint.name == "Head") ? new Vector3(8, 8, 8) : new Vector3(2, 2, 2);
        Matrix4x4 s = MatrixUtils.Scale(scalingVec);
        Matrix4x4 t = MatrixUtils.Translate(parentPosition + joint.offset);
        MatrixUtils.ApplyTransform(sphere, t * s);
        foreach (BVHJoint childJoint in joint.children)
        {
            CreateJoint(childJoint, sphere.transform.position);
        }

        return sphere;
    }


    // Transforms BVHJoint according to the keyframe channel data, and recursively transforms its children
    private void TransformJoint(BVHJoint joint, Matrix4x4 parentTransform, float[] keyframe)
    {
        // Your code here
    }

    // Update is called once per frame
    void Update()
    {
        if (animate)
        {
            // Your code here
        }
    }
}