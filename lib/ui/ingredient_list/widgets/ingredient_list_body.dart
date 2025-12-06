import 'package:flutter/material.dart';
import '../view_model/ingredient_list_viewmodel.dart';

class IngredientListBody extends StatelessWidget {
  const IngredientListBody({super.key, required this.viewModel});

  final IngredientListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: viewModel.getIngredients.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  Text(viewModel.getIngredients[index].name),
                  Divider(),
                ],
              );
            },
          );
  }
}
