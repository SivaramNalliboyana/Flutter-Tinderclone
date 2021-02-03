import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

Reference imagesbucket = FirebaseStorage.instance.ref().child("profilepics");
