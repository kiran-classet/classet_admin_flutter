import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:classet_admin/features/auth/providers/admin_user_provider.dart';
import 'dart:convert';

// Filter provider
final filterProvider = StateProvider<Map<String, String?>>((ref) => {
      'branch': null,
      'board': null,
      'grade': null,
      'section': null,
    });

// Mock JSON data (in a real app, this would come from an API)
const String branchesJson = '''
[
  {
    "key": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
    "name": "Meluha International School",
    "isActive": true,
    "branchCode": "MIS",
    "academicYear": "67a3391af6e827bc71c7befa"
  },
  {
    "key": "107dadea-3271-4434-8af9-83970247ae15",
    "name": "Gandipet",
    "isActive": true,
    "branchCode": "sr1",
    "academicYear": "67a3391af6e827bc71c7befa"
  }
]
''';

const String boardsJson = '''
[
        {
            "boardName": "Central Board of Secondary Education",
            "boardCode": "CBSE",
            "assignedBranches": [
                "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84"
            ],
            "description": "Central Board of Secondary Education",
            "academicCode": "67a3391af6e827bc71c7befa",
            "academicYear": "2024-2025",
            "boardId": "533d1812-02bd-48be-a89b-c9ca5e585301",
            "boardActivity": true,
            "classes": [
                {
                    "classId": "d59354b1-e288-45fb-829b-5acad553ea56",
                    "className": "Grade XII",
                    "classCode": "012",
                    "description": "Grade XII",
                    "priority": "12",
                    "isActivity": true,
                    "groups": [
                        {
                            "groupId": "71ccf958-990d-41c3-a8d5-a4122c3b9255",
                            "groupName": "NO_GROUP",
                            "isGroupActivity": true
                        }
                    ],
                    "sections": [
                        {
                            "_id": "67a45112c1d575ae8257d567",
                            "sectionId": "0c2e979e-70ed-465e-87e1-9da761b8bc73",
                            "autoCreate": true,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "XII-A",
                            "isActive": true,
                            "maxStrength": "100",
                            "priority": 1,
                            "sectionCode": "012",
                            "sectionName": "XII-A",
                            "assginedStrength": 63
                        },
                        {
                            "_id": "67aad9725bf1f0cbc879736a",
                            "sectionId": "e962d3f9-2554-4fb1-b179-1a8712a46a94",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "XII-B",
                            "isActive": true,
                            "maxStrength": "50",
                            "priority": 2,
                            "sectionCode": "012",
                            "sectionName": "XII-B",
                            "assginedStrength": 44
                        },
                        {
                            "_id": "67aad97f5bf1f0cbc879736b",
                            "sectionId": "b5ddc7c0-7c20-4362-9bca-5de8e4c5cad2",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "XII-C",
                            "isActive": true,
                            "maxStrength": "50",
                            "priority": 3,
                            "sectionCode": "012",
                            "sectionName": "XII-C",
                            "assginedStrength": 33
                        },
                        {
                            "_id": "67aad98f5bf1f0cbc879736c",
                            "sectionId": "519ec65d-a56b-4c53-8cfb-7b8da17fc9ca",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "XII-D",
                            "isActive": true,
                            "maxStrength": 50,
                            "priority": 4,
                            "sectionCode": "012",
                            "sectionName": "XII-D"
                        },
                        {
                            "_id": "67aad9a95bf1f0cbc879736d",
                            "sectionId": "5b56651b-4e15-4cf4-b7c7-64d3d8015117",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "XII-E",
                            "isActive": true,
                            "maxStrength": 50,
                            "priority": 5,
                            "sectionCode": "012",
                            "sectionName": "XII-E",
                            "assginedStrength": 22
                        },
                        {
                            "_id": "67aad9b55bf1f0cbc879736e",
                            "sectionId": "9750643a-38a8-4dec-8a88-e37aef8ba96f",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "XII-F",
                            "isActive": true,
                            "maxStrength": 50,
                            "priority": 6,
                            "sectionCode": "012",
                            "sectionName": "XII-F",
                            "assginedStrength": 13
                        },
                        {
                            "_id": "67aad9c35bf1f0cbc879736f",
                            "sectionId": "7be224c5-6c14-4088-8dd6-f777b607f299",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "XII-G",
                            "isActive": true,
                            "maxStrength": 50,
                            "priority": 7,
                            "sectionCode": "012",
                            "sectionName": "XII-G",
                            "assginedStrength": 9
                        },
                        {
                            "_id": "67aad9cf5bf1f0cbc8797370",
                            "sectionId": "0d4e829e-cfdf-4eda-a792-98ba0798a058",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "XII-H",
                            "isActive": true,
                            "maxStrength": 50,
                            "priority": 8,
                            "sectionCode": "012",
                            "sectionName": "XII-H",
                            "assginedStrength": 14
                        }
                    ],
                    "branches": [
                        {
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "branchName": "MELUHA INTERNATIONAL SCHOOL"
                        }
                    ]
                },
                {
                    "classId": "573852a8-7e2a-4b0f-8ad3-a06f1592fda7",
                    "className": "Grade XI",
                    "classCode": "011",
                    "description": "Grade XI",
                    "priority": "11",
                    "isActivity": true,
                    "groups": [
                        {
                            "groupId": "5c0f0bd9-2e9c-4f3f-9389-e0cb4657717d",
                            "groupName": "NO_GROUP",
                            "isGroupActivity": true
                        }
                    ],
                    "sections": [
                        {
                            "_id": "67a450e5c1d575ae8257d566",
                            "sectionId": "f4acfa76-14b1-4106-8342-d03e05e2e36f",
                            "autoCreate": true,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "XI-A",
                            "isActive": true,
                            "maxStrength": "100",
                            "priority": 1,
                            "sectionCode": "011",
                            "sectionName": "XI-A",
                            "assginedStrength": 42
                        },
                        {
                            "_id": "67aad8b05bf1f0cbc8797363",
                            "sectionId": "eaa3f0d3-e293-47a1-b4a4-57a7b481ae1d",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "XI-B",
                            "isActive": true,
                            "maxStrength": "100",
                            "priority": "2",
                            "sectionCode": "011",
                            "sectionName": "XI-B",
                            "assginedStrength": 44
                        },
                        {
                            "_id": "67aad8bb5bf1f0cbc8797364",
                            "sectionId": "58c4af4d-3b23-4ea6-9165-5eaae1c5c2cf",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "XI-C",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 3,
                            "sectionCode": "011",
                            "sectionName": "XI-C",
                            "assginedStrength": 33
                        },
                        {
                            "_id": "67aad8cb5bf1f0cbc8797365",
                            "sectionId": "bee68a0d-d0cf-4087-9e14-53d6cd3bfb2a",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "XI-D",
                            "isActive": true,
                            "maxStrength": 50,
                            "priority": "4",
                            "sectionCode": "011",
                            "sectionName": "XI-D"
                        },
                        {
                            "_id": "67aad8f65bf1f0cbc8797366",
                            "sectionId": "ccfec0c0-a53c-45ac-b7f0-fc06857f23ca",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "XI-E",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 5,
                            "sectionCode": "011",
                            "sectionName": "XI-E",
                            "assginedStrength": 29
                        },
                        {
                            "_id": "67aad9255bf1f0cbc8797367",
                            "sectionId": "ae98b617-0b44-4694-a1b0-be7d870f9f62",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "XI-F",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 6,
                            "sectionCode": "011",
                            "sectionName": "XI-F",
                            "assginedStrength": 33
                        },
                        {
                            "_id": "67aad9315bf1f0cbc8797368",
                            "sectionId": "71004fe8-a796-4dda-9bc7-31351515a782",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "XI-G",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 7,
                            "sectionCode": "011",
                            "sectionName": "XI-G",
                            "assginedStrength": 16
                        },
                        {
                            "_id": "67aad94f5bf1f0cbc8797369",
                            "sectionId": "f8d5a9ec-f22c-4952-9d57-e225b2cc34b4",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "XI-H",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 8,
                            "sectionCode": "011",
                            "sectionName": "XI-H",
                            "assginedStrength": 3
                        }
                    ],
                    "branches": [
                        {
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "branchName": "MELUHA INTERNATIONAL SCHOOL"
                        }
                    ]
                },
                {
                    "classId": "d451f630-f2a2-4f4f-9c90-b6519e82b8ef",
                    "className": "Grade X",
                    "classCode": "010",
                    "description": "Grade X",
                    "priority": "10",
                    "isActivity": true,
                    "groups": [
                        {
                            "groupId": "e7246465-fe19-4667-9af3-73007dcfbd5a",
                            "groupName": "NO_GROUP",
                            "isGroupActivity": true
                        }
                    ],
                    "sections": [
                        {
                            "_id": "67aad8515bf1f0cbc8797361",
                            "sectionId": "59ebc72b-fe19-409e-8c78-0f7f1f621eb0",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "X-B",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 2,
                            "sectionCode": "010",
                            "sectionName": "X-B",
                            "assginedStrength": 25
                        },
                        {
                            "_id": "67aad8695bf1f0cbc8797362",
                            "sectionId": "7fa2acab-ec73-428f-8efa-c4d6535c52a4",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "X-A",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 1,
                            "sectionCode": "010",
                            "sectionName": "X-A",
                            "assginedStrength": 24
                        },
                        {
                            "_id": "67af022f775aff71c753902e",
                            "sectionId": "b50ab0f2-d032-4b59-b9b0-2b4da708d54e",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "X-C",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 40,
                            "sectionCode": "10C",
                            "sectionName": "X-C",
                            "assginedStrength": 26
                        }
                    ],
                    "branches": [
                        {
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "branchName": "MELUHA INTERNATIONAL SCHOOL"
                        }
                    ]
                },
                {
                    "classId": "43d64508-4d5e-4739-ac86-4ea1b18fa591",
                    "className": "Grade IX",
                    "classCode": "009",
                    "description": "Grade IX",
                    "priority": "9",
                    "isActivity": true,
                    "groups": [
                        {
                            "groupId": "e1d85347-35a4-4495-8ef4-16a83ce4aeee",
                            "groupName": "NO_GROUP",
                            "isGroupActivity": true
                        }
                    ],
                    "sections": [
                        {
                            "_id": "67aad7fe5bf1f0cbc879735d",
                            "sectionId": "d4a458bc-aa37-4adf-9b95-9870ecbf2191",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "IX-A",
                            "isActive": true,
                            "maxStrength": "60",
                            "priority": 1,
                            "sectionCode": "009",
                            "sectionName": "IX-A",
                            "assginedStrength": 34
                        },
                        {
                            "_id": "67aad8405bf1f0cbc8797360",
                            "sectionId": "bc3179fa-9c57-4897-9a95-ec649de92822",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "IX-B",
                            "isActive": true,
                            "maxStrength": "60",
                            "priority": 2,
                            "sectionCode": "009",
                            "sectionName": "IX-B",
                            "assginedStrength": 34
                        }
                    ],
                    "branches": [
                        {
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "branchName": "MELUHA INTERNATIONAL SCHOOL"
                        }
                    ]
                },
                {
                    "classId": "0b0e425c-bf1a-496b-ac2c-46b6ab0b1c97",
                    "className": "Grade VIII",
                    "classCode": "008",
                    "description": "Grade VIII",
                    "priority": "8",
                    "isActivity": true,
                    "groups": [
                        {
                            "groupId": "d15f3f4e-e9a0-4719-845f-557ae7caa79b",
                            "groupName": "NO_GROUP",
                            "isGroupActivity": true
                        }
                    ],
                    "sections": [
                        {
                            "_id": "67aad7ee5bf1f0cbc879735c",
                            "sectionId": "516af6c3-2fb5-4576-9f48-e69db322aa89",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "VIII-A",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 1,
                            "sectionCode": "008",
                            "sectionName": "VIII-A",
                            "assginedStrength": 26
                        },
                        {
                            "_id": "67aad8355bf1f0cbc879735f",
                            "sectionId": "885c7acb-b1d8-420f-90c2-a6cb3f4ce2f7",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "VIII-B",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 2,
                            "sectionCode": "008",
                            "sectionName": "VIII-B",
                            "assginedStrength": 24
                        }
                    ],
                    "branches": [
                        {
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "branchName": "MELUHA INTERNATIONAL SCHOOL"
                        }
                    ]
                },
                {
                    "classId": "13c975e7-0210-4c35-a93c-2facd990fa01",
                    "className": "Grade VII",
                    "classCode": "007",
                    "description": "Grade VII",
                    "priority": "7",
                    "isActivity": true,
                    "groups": [
                        {
                            "groupId": "21f7870e-6b8c-459c-9a3c-2c6fd3f9a353",
                            "groupName": "NO_GROUP",
                            "isGroupActivity": true
                        }
                    ],
                    "sections": [
                        {
                            "_id": "67aad7df5bf1f0cbc879735b",
                            "sectionId": "9bdec2f0-a9b7-4c40-bcd7-4d718a10301b",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "VII-A",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 1,
                            "sectionCode": "007",
                            "sectionName": "VII-A",
                            "assginedStrength": 20
                        },
                        {
                            "_id": "67aad8165bf1f0cbc879735e",
                            "sectionId": "266a268c-0a2b-42a4-af94-5c429cf13ac9",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "VII-B",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 2,
                            "sectionCode": "007",
                            "sectionName": "VII-B",
                            "assginedStrength": 20
                        }
                    ],
                    "branches": [
                        {
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "branchName": "MELUHA INTERNATIONAL SCHOOL"
                        }
                    ]
                },
                {
                    "classId": "e0993f4d-9595-4887-a987-6d14af0616a0",
                    "className": "Grade VI",
                    "classCode": "006",
                    "description": "Grade VI",
                    "priority": "6",
                    "isActivity": true,
                    "groups": [
                        {
                            "groupId": "0467d3eb-fc55-4079-b5dc-5d56c9ce71ae",
                            "groupName": "NO_GROUP",
                            "isGroupActivity": true
                        }
                    ],
                    "sections": [
                        {
                            "_id": "67aad7d35bf1f0cbc879735a",
                            "sectionId": "daf7c9bf-bd95-45eb-827a-b98cde9341ef",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "VI-A",
                            "isActive": true,
                            "maxStrength": "60",
                            "priority": 1,
                            "sectionCode": "006",
                            "sectionName": "VI-A",
                            "assginedStrength": 21
                        }
                    ],
                    "branches": [
                        {
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "branchName": "MELUHA INTERNATIONAL SCHOOL"
                        }
                    ]
                },
                {
                    "classId": "5bebb212-3da7-41c5-93ce-d927f3228c06",
                    "className": "Grade V",
                    "classCode": "005",
                    "description": "Grade V",
                    "priority": "5",
                    "isActivity": true,
                    "groups": [
                        {
                            "groupId": "8385b733-07f0-486f-b444-dc886b5fd861",
                            "groupName": "NO_GROUP",
                            "isGroupActivity": true
                        }
                    ],
                    "sections": [
                        {
                            "_id": "67aad7885bf1f0cbc8797359",
                            "sectionId": "26ea9391-55f2-4f33-8769-ee531a8d4af8",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "V-A",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 1,
                            "sectionCode": "005",
                            "sectionName": "V-A",
                            "assginedStrength": 4
                        }
                    ],
                    "branches": [
                        {
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "branchName": "MELUHA INTERNATIONAL SCHOOL"
                        }
                    ]
                },
                {
                    "classId": "17741752-76fa-4776-959d-4bb46c95a5e7",
                    "className": "Grade IV",
                    "classCode": "004",
                    "description": "Grade IV",
                    "priority": "4",
                    "isActivity": true,
                    "groups": [
                        {
                            "groupId": "12368d8b-ee0d-4bbd-bff2-2cae2197ec5e",
                            "groupName": "NO_GROUP",
                            "isGroupActivity": true
                        }
                    ],
                    "sections": [
                        {
                            "_id": "67aad7765bf1f0cbc8797358",
                            "sectionId": "2d98bec5-32f0-4c6a-8413-fd88d1a93a75",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "IV-A",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 1,
                            "sectionCode": "004",
                            "sectionName": "IV-A",
                            "assginedStrength": 2
                        }
                    ],
                    "branches": [
                        {
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "branchName": "MELUHA INTERNATIONAL SCHOOL"
                        }
                    ]
                },
                {
                    "classId": "7b0bf47b-ff23-419b-8e61-2b1c66a6dd57",
                    "className": "Grade III",
                    "classCode": "003",
                    "description": "Grade III",
                    "priority": "3",
                    "isActivity": true,
                    "groups": [
                        {
                            "groupId": "1e781f00-d258-4b4c-a7c8-30b7f5a4d093",
                            "groupName": "NO_GROUP",
                            "isGroupActivity": true
                        }
                    ],
                    "sections": [
                        {
                            "_id": "67aad7665bf1f0cbc8797357",
                            "sectionId": "389b5511-ff2e-4bb7-81cc-8202321113cf",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "III-A",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 1,
                            "sectionCode": "003",
                            "sectionName": "III-A",
                            "assginedStrength": 3
                        }
                    ],
                    "branches": [
                        {
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "branchName": "MELUHA INTERNATIONAL SCHOOL"
                        }
                    ]
                },
                {
                    "classId": "4daefa7d-8987-460d-80ee-18e53c67b00e",
                    "className": "Grade II",
                    "classCode": "002",
                    "description": "Grade II",
                    "priority": "2",
                    "isActivity": true,
                    "groups": [
                        {
                            "groupId": "acfae67e-48c5-4b31-b618-cabb97f1fb4b",
                            "groupName": "NO_GROUP",
                            "isGroupActivity": true
                        }
                    ],
                    "sections": [
                        {
                            "_id": "67aad7585bf1f0cbc8797356",
                            "sectionId": "77a3408b-5594-4abb-b6b5-b263963ae276",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "II-A",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 1,
                            "sectionCode": "002",
                            "sectionName": "II-A"
                        }
                    ],
                    "branches": [
                        {
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "branchName": "MELUHA INTERNATIONAL SCHOOL"
                        }
                    ]
                },
                {
                    "classId": "cfc0d07e-bd86-4b55-959b-e1db2c633851",
                    "className": "Grade I",
                    "classCode": "001",
                    "description": "Grade I",
                    "priority": "1",
                    "isActivity": true,
                    "groups": [
                        {
                            "groupId": "f67b3214-efa6-4b0c-943f-e6b41adaa1e5",
                            "groupName": "NO_GROUP",
                            "isGroupActivity": true
                        }
                    ],
                    "sections": [
                        {
                            "_id": "67aad7385bf1f0cbc8797355",
                            "sectionId": "bbc80b4c-be93-4d61-a1f6-59ce86cac31a",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "I-A",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 1,
                            "sectionCode": "I-A",
                            "sectionName": "I-A",
                            "assginedStrength": 3
                        }
                    ],
                    "branches": [
                        {
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "branchName": "MELUHA INTERNATIONAL SCHOOL"
                        }
                    ]
                }
            ],
            "startDate": "2024-05-31T18:30:00.000Z",
            "endDate": "2025-05-30T18:30:00.000Z"
        },
        {
            "boardName": "International Baccalaureate",
            "boardCode": "IB",
            "assignedBranches": [
                "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84"
            ],
            "description": "International Baccalaureate",
            "academicCode": "67a3391af6e827bc71c7befa",
            "academicYear": "2024-2025",
            "boardId": "8fae8765-518c-4deb-8d35-2f2c5c554720",
            "boardActivity": true,
            "classes": [
                {
                    "classId": "3883ec51-8846-4abe-a54c-6b2055111015",
                    "className": "IBCP-AI",
                    "classCode": "IAI",
                    "description": "IBCP-AI",
                    "priority": "1",
                    "isActivity": true,
                    "groups": [
                        {
                            "groupId": "5aa8d0b8-4cd2-4232-ba01-ff05436e739a",
                            "groupName": "NO_GROUP",
                            "isGroupActivity": true
                        }
                    ],
                    "sections": [
                        {
                            "_id": "67aada935bf1f0cbc8797371",
                            "sectionId": "b4279186-51a2-4d46-a52d-b243d39dc462",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "AI-A",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 1,
                            "sectionCode": "011",
                            "sectionName": "AI-A"
                        }
                    ],
                    "branches": [
                        {
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "branchName": "MELUHA INTERNATIONAL SCHOOL"
                        }
                    ]
                },
                {
                    "classId": "d3d28f4e-bb1b-41d0-996d-7188a263b0fb",
                    "className": "IBCP-BA",
                    "classCode": "IBA",
                    "description": "IBCP-BA",
                    "priority": "2",
                    "isActivity": true,
                    "groups": [
                        {
                            "groupId": "57deb2c7-0005-474e-94b4-b018883427bb",
                            "groupName": "NO_GROUP",
                            "isGroupActivity": true
                        }
                    ],
                    "sections": [
                        {
                            "_id": "67aadaa85bf1f0cbc8797372",
                            "sectionId": "a4e28f5f-8088-47ed-ac4a-2f5a559df0a2",
                            "autoCreate": false,
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "description": "BA-A",
                            "isActive": true,
                            "maxStrength": 40,
                            "priority": 1,
                            "sectionCode": "011",
                            "sectionName": "BA-A"
                        }
                    ],
                    "branches": [
                        {
                            "branchId": "8c3e5ac6-0ec1-41d6-8b64-f368036f3a84",
                            "branchName": "MELUHA INTERNATIONAL SCHOOL"
                        }
                    ]
                }
            ],
            "startDate": "2024-05-31T18:30:00.000Z",
            "endDate": "2025-05-30T18:30:00.000Z"
        }
    ]
''';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminUserState = ref.watch(adminUserProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 10.0,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                adminUserState.isLoading
                    ? _buildShimmerEffect()
                    : _buildQuickStats(context),
                const SizedBox(height: 20),
                adminUserState.isLoading
                    ? _buildShimmerEffect()
                    : _buildSectionTitle(context, 'Quick Actions'),
                const SizedBox(height: 10),
                adminUserState.isLoading
                    ? _buildShimmerEffect()
                    : _buildQuickActions(context),
                const SizedBox(height: 20),
                _buildSectionTitle(context, 'Recent Activities'),
                const SizedBox(height: 10),
                adminUserState.isLoading
                    ? _buildShimmerEffect()
                    : _buildRecentActivities(context),
                const SizedBox(height: 20),
                adminUserState.isLoading
                    ? _buildShimmerEffect()
                    : _buildSectionTitle(context, 'Key Metrics'),
                const SizedBox(height: 10),
                adminUserState.isLoading
                    ? _buildShimmerEffect()
                    : _buildKeyMetrics(context),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterBottomSheet(context, ref),
        child: const Icon(Icons.filter_list),
        tooltip: 'Filter',
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'School Dashboard Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundImage:
              NetworkImage('https://misedu-manage.classet.in/profilew.jpg'),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, '1,234', 'Total\nStudents'),
          _buildDivider(),
          _buildStatItem(context, '85%', 'Attendance\nRate'),
          _buildDivider(),
          _buildStatItem(context, '95%', 'Fee\nCollection'),
          _buildDivider(),
          _buildStatItem(context, '45', 'Active\nTeachers'),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildActionItem(context, 'Admissions', Icons.school, Colors.blue),
        _buildActionItem(context, 'Attendance', Icons.fact_check, Colors.green),
        _buildActionItem(
            context, 'Finance', Icons.account_balance_wallet, Colors.purple),
        _buildActionItem(
            context, 'Transport', Icons.directions_bus, Colors.orange),
      ],
    );
  }

  Widget _buildActionItem(
      BuildContext context, String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildActivityItem(context, _getActivityData(index));
        },
      ),
    );
  }

  Map<String, dynamic> _getActivityData(int index) {
    final activities = [
      {
        'title': 'New Admission',
        'description': 'John Doe admitted to Class 10-A',
        'time': '2 hours ago',
        'icon': Icons.person_add,
        'color': Colors.green,
      },
      {
        'title': 'Fee Collection',
        'description': 'Received ₹25,000 from Class 9 students',
        'time': '3 hours ago',
        'icon': Icons.payment,
        'color': Colors.blue,
      },
      {
        'title': 'Attendance Update',
        'description': 'Class 8 attendance marked for today',
        'time': '4 hours ago',
        'icon': Icons.fact_check,
        'color': Colors.orange,
      },
      {
        'title': 'Transport Alert',
        'description': 'Bus 02 route updated for evening schedule',
        'time': '5 hours ago',
        'icon': Icons.directions_bus,
        'color': Colors.purple,
      },
      {
        'title': 'Teacher Diary',
        'description': 'Mathematics class notes updated for Class 10',
        'time': '6 hours ago',
        'icon': Icons.book,
        'color': Colors.red,
      },
    ];
    return activities[index];
  }

  Widget _buildActivityItem(
      BuildContext context, Map<String, dynamic> activity) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: activity['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          activity['icon'],
          color: activity['color'],
        ),
      ),
      title: Text(
        activity['title'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(activity['description']),
      trailing: Text(
        activity['time'],
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem(
                context,
                'Students',
                '1,234',
                Icons.trending_up,
                Colors.green,
                '+5% this month',
              ),
              _buildMetricItem(
                context,
                'Revenue',
                '₹5.2L',
                Icons.trending_up,
                Colors.green,
                '+12% this month',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem(
                context,
                'Attendance',
                '85%',
                Icons.trending_down,
                Colors.red,
                '-2% this week',
              ),
              _buildMetricItem(
                context,
                'Transport',
                '15 Routes',
                Icons.trending_flat,
                Colors.orange,
                'No change',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(BuildContext context, String label, String value,
      IconData trendIcon, Color trendColor, String trendLabel) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                trendIcon,
                color: trendColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                trendLabel,
                style: TextStyle(
                  color: trendColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    final branches = jsonDecode(branchesJson) as List<dynamic>;
    final boards = jsonDecode(boardsJson) as List<dynamic>;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer(
        builder: (context, dialogRef, child) {
          final filters = dialogRef.watch(filterProvider);

          // Get boards for selected branch
          List<dynamic> availableBoards = filters['branch'] != null
              ? boards
                  .where((board) => (board['assignedBranches'] as List)
                      .contains(filters['branch']))
                  .toList()
              : [];

          // Get classes (grades) for selected board
          List<dynamic> availableClasses = filters['board'] != null
              ? (boards.firstWhere(
                      (board) => board['boardId'] == filters['board'],
                      orElse: () => {'classes': []})['classes'] as List)
                  .toList()
              : [];

          // Get sections for selected grade and branch
          List<dynamic> availableSections = filters['grade'] != null &&
                  filters['branch'] != null
              ? (availableClasses.firstWhere(
                      (cls) => cls['classId'] == filters['grade'],
                      orElse: () => {'sections': []})['sections'] as List)
                  .where((section) => section['branchId'] == filters['branch'])
                  .toList()
              : [];

          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilterSection(
                          title: 'Branch',
                          items:
                              branches.map((b) => b['key'] as String).toList(),
                          displayItems:
                              branches.map((b) => b['name'] as String).toList(),
                          selectedItem: filters['branch'],
                          onSelected: (value) {
                            final newValue =
                                value == filters['branch'] ? null : value;
                            dialogRef.read(filterProvider.notifier).state = {
                              'branch': newValue,
                              'board': null,
                              'grade': null,
                              'section': null,
                            };
                          },
                        ),
                        if (filters['branch'] != null) ...[
                          const SizedBox(height: 24),
                          _buildFilterSection(
                            title: 'Board',
                            items: availableBoards
                                .map((b) => b['boardId'] as String)
                                .toList(),
                            displayItems: availableBoards
                                .map((b) => b['boardName'] as String)
                                .toList(),
                            selectedItem: filters['board'],
                            onSelected: (value) {
                              final newValue =
                                  value == filters['board'] ? null : value;
                              dialogRef.read(filterProvider.notifier).state = {
                                ...filters,
                                'board': newValue,
                                'grade': null,
                                'section': null,
                              };
                            },
                          ),
                        ],
                        if (filters['board'] != null) ...[
                          const SizedBox(height: 24),
                          _buildFilterSection(
                            title: 'Grade',
                            items: availableClasses
                                .map((c) => c['classId'] as String)
                                .toList(),
                            displayItems: availableClasses
                                .map((c) => c['className'] as String)
                                .toList(),
                            selectedItem: filters['grade'],
                            onSelected: (value) {
                              final newValue =
                                  value == filters['grade'] ? null : value;
                              dialogRef.read(filterProvider.notifier).state = {
                                ...filters,
                                'grade': newValue,
                                'section': null,
                              };
                            },
                          ),
                        ],
                        if (filters['grade'] != null) ...[
                          const SizedBox(height: 24),
                          _buildFilterSection(
                            title: 'Section',
                            items: availableSections
                                .map((s) => s['sectionId'] as String)
                                .toList(),
                            displayItems: availableSections
                                .map((s) => s['sectionName'] as String)
                                .toList(),
                            selectedItem: filters['section'],
                            onSelected: (value) {
                              final newValue =
                                  value == filters['section'] ? null : value;
                              dialogRef.read(filterProvider.notifier).state = {
                                ...filters,
                                'section': newValue,
                              };
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          dialogRef.read(filterProvider.notifier).state = {
                            'branch': null,
                            'board': null,
                            'grade': null,
                            'section': null,
                          };
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final currentFilters = ref.read(filterProvider);
                          print('Applied filters: $currentFilters');
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> items,
    required List<String> displayItems,
    required String? selectedItem,
    required void Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Text('No options available')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final displayName = displayItems[index];
              final isSelected = selectedItem == item;
              return FilterChip(
                label: Text(displayName),
                selected: isSelected,
                onSelected: (_) => onSelected(item),
                selectedColor: Colors.blue.withOpacity(0.2),
                checkmarkColor: Colors.blue,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
