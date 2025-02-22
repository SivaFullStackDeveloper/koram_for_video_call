class incompleteDatingReg {
  String? type;
  String? message;
  List<String>? imcompleteList;

  incompleteDatingReg({this.type, this.message, this.imcompleteList});

  incompleteDatingReg.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    message = json['message'];
    imcompleteList = json['imcompleteList'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['message'] = this.message;
    data['imcompleteList'] = this.imcompleteList;
    return data;
  }
}