import 'package:flutter/material.dart';
import '../view_model/ingredient_list_viewmodel.dart';

class IngredientListBody extends StatelessWidget {
  const IngredientListBody({super.key, required this.viewModel});

  final IngredientListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    viewModel.setFilteredIngredients('');
    return Column(
      children: [
        SearchBar(
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          onChanged: (value) => viewModel.setFilteredIngredients(value),
        ),
        SizedBox(height: 10,),
        ListenableBuilder(
          listenable: viewModel.loadIngredientList,
          builder: (context, child) {
            return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: viewModel.getFilteredIngredients.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    Text(viewModel.getFilteredIngredients[index].name),
                    Divider(),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
