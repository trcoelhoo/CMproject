
import 'package:projeto/repositories/group/base_group_rep.dart';
import 'package:projeto/repositories/group/group_rep.dart';

import '../../group.dart';


class GroupCreate extends BaseGroupRep{
  GroupCreate();
  @override
  Future<Group> createGroup() async {
    return await Group();
  }

}