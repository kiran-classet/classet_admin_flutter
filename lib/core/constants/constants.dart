import 'dart:convert';

const String branchToSectionsJson = '''
 {
                "orgId": "675d109151233718e9b76de8",
                "orgName": "Testing Organization ",
                "branches": [
                    {
                        "branchId": "03788c5e-41a6-44be-a7e9-76f58bf61690",
                        "branchName": "Branch 1",
                        "boards": [
                            {
                                "boardId": "8ae27b15-a7c9-4c38-8220-a892cd7ae748",
                                "boardName": "Board 1",
                                "classes": [
                                    {
                                        "classId": "a513e79f-f5b5-485f-9ff3-072a69bbe795",
                                        "className": "Grade 1",
                                        "sections": [
                                            {
                                                "sectionId": "c8e11add-1285-4b7a-b1e0-fc41604b5de7",
                                                "sectionName": "Section 1"
                                            },
                                            {
                                                "sectionId": "8c70c3eb-2789-4042-a5c7-47c6b620ada6",
                                                "sectionName": "SECTION 2"
                                            },
                                            {
                                                "sectionId": "2bbea4ec-0978-4961-8af6-5f58f94afbeb",
                                                "sectionName": "Section3"
                                            },
                                            {
                                                "sectionId": "9a994151-7613-4063-ab1d-0f7a81ed3eda",
                                                "sectionName": "Section4"
                                            },
                                            {
                                                "sectionId": "ee8a3e48-76f0-4a40-9ae2-9e42764ea8ed",
                                                "sectionName": "Section5"
                                            },
                                            {
                                                "sectionId": "5fbba41b-36f3-43ec-80f3-255e0ee0bb78",
                                                "sectionName": "Section6"
                                            }
                                        ]
                                    },
                                    {
                                        "classId": "3bd41ce2-cb4c-4ac4-86e7-f42ad73a4c4f",
                                        "className": "Grade2",
                                        "sections": [
                                            {
                                                "sectionId": "38758141-43ba-4afd-8206-553c25c7db48",
                                                "sectionName": "SECTION 1"
                                            },
                                            {
                                                "sectionId": "c6966f18-b20b-4d61-8eac-be94520a34c1",
                                                "sectionName": "SEction@2"
                                            }
                                        ]
                                    },
                                    {
                                        "classId": "41e48c86-bd22-48b1-8a9b-566c5f57d8ad",
                                        "className": "grade 3",
                                        "sections": []
                                    }
                                ]
                            },
                            {
                                "boardId": "27484d28-66a8-4bb7-b907-56161ca22d9d",
                                "boardName": "Board4",
                                "classes": [
                                    {
                                        "classId": "a0eccc2a-a475-4681-be11-d9d9d19910da",
                                        "className": "GradeB4",
                                        "sections": []
                                    }
                                ]
                            },
                            {
                                "boardId": "77b33ebe-bc89-4772-84d1-d27185635393",
                                "boardName": "Board7",
                                "classes": [
                                    {
                                        "classId": "797a9dbe-75c6-408f-85d7-c8425b4245d8",
                                        "className": "B7Grade",
                                        "sections": [
                                            {
                                                "sectionId": "d84d67e9-0ba6-4808-8692-125c35471799",
                                                "sectionName": "section1"
                                            },
                                            {
                                                "sectionId": "b274451f-4d2d-4c32-920a-29c014024a05",
                                                "sectionName": "section2 b7"
                                            }
                                        ]
                                    }
                                ]
                            },
                            {
                                "boardId": "220e6a0e-aafb-40c0-bdc5-c041e697ca75",
                                "boardName": "Board8",
                                "classes": [
                                    {
                                        "classId": "44857f07-d007-4297-9593-e1db4041263d",
                                        "className": "GradeB8",
                                        "sections": [
                                            {
                                                "sectionId": "3f390196-b88a-4270-bc17-656f0cd34889",
                                                "sectionName": "SEctkion 1"
                                            },
                                            {
                                                "sectionId": "9f1b9edd-ef51-4e22-95c1-fa7d623a7b14",
                                                "sectionName": "Section2"
                                            }
                                        ]
                                    }
                                ]
                            },
                            {
                                "boardId": "4f09336c-cdde-41db-816c-8e03251cdd52",
                                "boardName": "Board9",
                                "classes": [
                                    {
                                        "classId": "a8a790bd-7089-4373-bdb0-2373c6caeee1",
                                        "className": "GinB9",
                                        "sections": []
                                    }
                                ]
                            },
                            {
                                "boardId": "8cedbd8b-4ce2-4817-8fbf-0ba13dd3ecbe",
                                "boardName": "Board10",
                                "classes": [
                                    {
                                        "classId": "29ed71ce-dc9a-4b33-ad3c-08de91351967",
                                        "className": "GrB10",
                                        "sections": [
                                            {
                                                "sectionId": "72200b6c-27c9-4f67-ac11-749e245830c0",
                                                "sectionName": "Section1"
                                            }
                                        ]
                                    }
                                ]
                            },
                            {
                                "boardId": "d71f8871-2e67-4cbb-8279-9a42e7709e16",
                                "boardName": "IB Board",
                                "classes": [
                                    {
                                        "classId": "531d28af-db62-44f0-9b27-51c37c0caa65",
                                        "className": "IB Grade1",
                                        "sections": [
                                            {
                                                "sectionId": "bef97638-f0bb-41b3-8426-c379482dccbb",
                                                "sectionName": "IBG1 Section1"
                                            }
                                        ]
                                    },
                                    {
                                        "classId": "67827bdb-690e-4f1a-b8c0-77d3360f7f3d",
                                        "className": "IB Grade2",
                                        "sections": [
                                            {
                                                "sectionId": "09baf7bd-2a79-422f-82d6-2ec54e550769",
                                                "sectionName": "IBG2 Section1"
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    },
                    {
                        "branchId": "4f4115a6-49c5-4301-8abc-f376050786cf",
                        "branchName": "Branch2",
                        "boards": [
                            {
                                "boardId": "2a15f240-764a-4d55-ad69-48ffccdc41a9",
                                "boardName": "Board2",
                                "classes": [
                                    {
                                        "classId": "9143ea99-b889-47cb-ab78-09c9163bc1ed",
                                        "className": "Grade1-br2",
                                        "sections": [
                                            {
                                                "sectionId": "74d5abeb-48b5-4226-84aa-0522b7eaec46",
                                                "sectionName": "s2frombr2"
                                            },
                                            {
                                                "sectionId": "9509ecd7-fb57-44f2-a192-93b54af79aad",
                                                "sectionName": "Section2"
                                            }
                                        ]
                                    }
                                ]
                            },
                            {
                                "boardId": "3ed5c2ce-d1ec-46ee-9a60-0f3bdf022c42",
                                "boardName": "Board3",
                                "classes": [
                                    {
                                        "classId": "a55caa86-158a-431a-9c16-72331f35a081",
                                        "className": "Grade1",
                                        "sections": [
                                            {
                                                "sectionId": "cd3c1016-4e61-4fde-a583-731355078337",
                                                "sectionName": "section1"
                                            },
                                            {
                                                "sectionId": "dc80273a-b9d3-4dee-b12a-386173c82fde",
                                                "sectionName": "Section2"
                                            }
                                        ]
                                    }
                                ]
                            },
                            {
                                "boardId": "6dcbdeff-a2f1-4aba-8bd3-f8878d7b8424",
                                "boardName": "Board5",
                                "classes": [
                                    {
                                        "classId": "30f5b1ca-5d58-4732-a589-b97b584d801b",
                                        "className": "Grade1",
                                        "sections": [
                                            {
                                                "sectionId": "cea4f0f4-810d-4c01-be16-76058bfd4516",
                                                "sectionName": "Section 1"
                                            },
                                            {
                                                "sectionId": "63267179-5d51-4c11-a14f-224c6804785e",
                                                "sectionName": "Section2"
                                            }
                                        ]
                                    }
                                ]
                            },
                            {
                                "boardId": "60ffed57-4a87-4a6d-8bbd-f8e5891adbea",
                                "boardName": "Board6",
                                "classes": [
                                    {
                                        "classId": "a4f428d9-90c0-46e4-b607-544c37ff801f",
                                        "className": "GradeB6",
                                        "sections": [
                                            {
                                                "sectionId": "44bb01f0-5270-4022-a533-77c6dd36ad23",
                                                "sectionName": "Section 1"
                                            },
                                            {
                                                "sectionId": "8dcb156a-2dd5-4fe8-8e8b-50893d41be4e",
                                                "sectionName": "Section2"
                                            },
                                            {
                                                "sectionId": "10e64cef-6b87-4e31-a5ad-1bb3beec87e0",
                                                "sectionName": "Section3"
                                            }
                                        ]
                                    }
                                ]
                            },
                            {
                                "boardId": "d71f8871-2e67-4cbb-8279-9a42e7709e16",
                                "boardName": "IB Board",
                                "classes": [
                                    {
                                        "classId": "531d28af-db62-44f0-9b27-51c37c0caa65",
                                        "className": "IB Grade1",
                                        "sections": []
                                    },
                                    {
                                        "classId": "67827bdb-690e-4f1a-b8c0-77d3360f7f3d",
                                        "className": "IB Grade2",
                                        "sections": []
                                    }
                                ]
                            }
                        ]
                    },
                    {
                        "branchId": "95b6a356-a72b-4f30-9de7-8801b796f586",
                        "branchName": "Branch4",
                        "boards": [
                            {
                                "boardId": "8ae27b15-a7c9-4c38-8220-a892cd7ae748",
                                "boardName": "Board 1",
                                "classes": [
                                    {
                                        "classId": "a513e79f-f5b5-485f-9ff3-072a69bbe795",
                                        "className": "Grade 1",
                                        "sections": []
                                    },
                                    {
                                        "classId": "3bd41ce2-cb4c-4ac4-86e7-f42ad73a4c4f",
                                        "className": "Grade2",
                                        "sections": []
                                    },
                                    {
                                        "classId": "41e48c86-bd22-48b1-8a9b-566c5f57d8ad",
                                        "className": "grade 3",
                                        "sections": []
                                    }
                                ]
                            },
                            {
                                "boardId": "2a15f240-764a-4d55-ad69-48ffccdc41a9",
                                "boardName": "Board2",
                                "classes": [
                                    {
                                        "classId": "9143ea99-b889-47cb-ab78-09c9163bc1ed",
                                        "className": "Grade1-br2",
                                        "sections": []
                                    }
                                ]
                            }
                        ]
                    },
                    {
                        "branchId": "b8a7ad5c-80c6-4cac-b247-54983ace4aeb",
                        "branchName": "Branch 710",
                        "boards": [
                            {
                                "boardId": "92c060f8-96d6-4c2b-9bc9-bac123c3fef2",
                                "boardName": "BoardTest",
                                "classes": [
                                    {
                                        "classId": "9d5c99d5-5fee-4e4e-908d-eef7e0ee6935",
                                        "className": "GradeTest",
                                        "sections": [
                                            {
                                                "sectionId": "295c73bb-059c-4920-81ec-183b2641853d",
                                                "sectionName": "SectionTest1"
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    },
                    {
                        "branchId": "beafe20e-df5c-44ba-bfe1-eeb37f177b16",
                        "branchName": "Demo branch",
                        "boards": [
                            {
                                "boardId": "76fc6e90-9a30-4e24-8857-8ae901c7edd0",
                                "boardName": "CBSE",
                                "classes": [
                                    {
                                        "classId": "927ad2ad-194a-42cc-9744-40c041c693d7",
                                        "className": "Grade1",
                                        "sections": [
                                            {
                                                "sectionId": "e4af0678-3065-4d74-a29b-aea26d365720",
                                                "sectionName": "section1"
                                            },
                                            {
                                                "sectionId": "49dbb344-f21f-429f-97d9-c408cce5bdde",
                                                "sectionName": "section2"
                                            }
                                        ]
                                    },
                                    {
                                        "classId": "6363cd7f-b00d-49ce-b236-7311692876d1",
                                        "className": "Grade2",
                                        "sections": [
                                            {
                                                "sectionId": "68a807c1-ed7d-47db-983f-c25528d12016",
                                                "sectionName": "section1"
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
''';

List<Map<String, dynamic>> getBranches() {
  final data = json.decode(branchToSectionsJson);
  return List<Map<String, dynamic>>.from(data['branches']);
}

List<Map<String, dynamic>> getBoards(String branchId) {
  final branches = getBranches();
  final branch =
      branches.firstWhere((b) => b['branchId'] == branchId, orElse: () => {});
  return branch != null
      ? List<Map<String, dynamic>>.from(branch['boards'])
      : [];
}

List<Map<String, dynamic>> getClasses(String branchId, String boardId) {
  final boards = getBoards(branchId);
  final board =
      boards.firstWhere((b) => b['boardId'] == boardId, orElse: () => {});
  return board != null ? List<Map<String, dynamic>>.from(board['classes']) : [];
}

List<Map<String, dynamic>> getSections(
    String branchId, String boardId, String classId) {
  final classes = getClasses(branchId, boardId);
  final classItem =
      classes.firstWhere((c) => c['classId'] == classId, orElse: () => {});
  return classItem != null
      ? List<Map<String, dynamic>>.from(classItem['sections'])
      : [];
}
