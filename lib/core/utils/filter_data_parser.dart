class FilterDataParser {
  static List<Map<String, dynamic>> getBranchesFromUserDetails(
      Map<String, dynamic> userDetails) {
    try {
      final data = userDetails['data'];
      final userInfo = data['user_info'];
      final branchToSections = userInfo['branchTosections'];
      final branches = branchToSections['branches'] as List;

      return branches
          .map((branch) => {
                'branchId': branch['branchId'],
                'branchName': branch['branchName'],
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getBoardsFromBranch(
      Map<String, dynamic> userDetails, String branchId) {
    try {
      final data = userDetails['data'];
      final userInfo = data['user_info'];
      final branchToSections = userInfo['branchTosections'];
      final branches = branchToSections['branches'] as List;

      final branch = branches.firstWhere((b) => b['branchId'] == branchId);
      final boards = branch['boards'] as List;

      return boards
          .map((board) => {
                'boardId': board['boardId'],
                'boardName': board['boardName'],
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getClassesFromBoard(
      Map<String, dynamic> userDetails, String branchId, String boardId) {
    try {
      final data = userDetails['data'];
      final userInfo = data['user_info'];
      final branchToSections = userInfo['branchTosections'];
      final branches = branchToSections['branches'] as List;

      final branch = branches.firstWhere((b) => b['branchId'] == branchId);
      final board = branch['boards'].firstWhere((b) => b['boardId'] == boardId);
      final classes = board['classes'] as List;

      return classes
          .map((cls) => {
                'classId': cls['classId'],
                'className': cls['className'],
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getSectionsFromClass(
      Map<String, dynamic> userDetails,
      String branchId,
      String boardId,
      String classId) {
    try {
      final data = userDetails['data'];
      final userInfo = data['user_info'];
      final branchToSections = userInfo['branchTosections'];
      final branches = branchToSections['branches'] as List;

      final branch = branches.firstWhere((b) => b['branchId'] == branchId);
      final board = branch['boards'].firstWhere((b) => b['boardId'] == boardId);
      final cls = board['classes'].firstWhere((c) => c['classId'] == classId);
      final sections = cls['sections'] as List;

      return sections
          .map((section) => {
                'sectionId': section['sectionId'],
                'sectionName': section['sectionName'],
              })
          .toList();
    } catch (e) {
      return [];
    }
  }
}
